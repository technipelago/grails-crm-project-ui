package grails.plugins.crm.project

import grails.converters.JSON
import grails.plugins.crm.core.*
import grails.transaction.Transactional
import org.springframework.dao.DataIntegrityViolationException

import javax.servlet.http.HttpServletResponse
import java.util.concurrent.TimeoutException

/**
 * Main Project Management controller.
 */
class CrmProjectController {

    static allowedMethods = [list: ['GET', 'POST'], create: ['GET', 'POST'], edit: ['GET', 'POST'], delete: 'POST']

    def crmCoreService
    def crmSecurityService
    def crmProjectService
    def crmContactService
    def selectionService
    def userTagService
    def pluginManager

    def index() {
        // If any query parameters are specified in the URL, let them override the last query stored in session.
        def cmd = new CrmProjectQueryCommand()
        def query = params.getSelectionQuery()
        bindData(cmd, query ?: WebUtils.getTenantData(request, 'crmProjectQuery'))
        [cmd: cmd]
    }

    def list() {
        def baseURI = new URI('bean://crmProjectService/list')
        def query = params.getSelectionQuery()
        def uri

        switch (request.method) {
            case 'GET':
                uri = params.getSelectionURI() ?: selectionService.addQuery(baseURI, query)
                break
            case 'POST':
                uri = selectionService.addQuery(baseURI, query)
                WebUtils.setTenantData(request, 'crmProjectQuery', query)
                break
        }

        params.max = Math.min(params.max ? params.int('max') : 10, 100)

        def result
        try {
            result = selectionService.select(uri, params)
            if (result.totalCount == 1 && params.view != 'list') {
                redirect action: "show", params: selectionService.createSelectionParameters(uri) + [id: result.head().ident()]
            } else {
                [crmProjectList : result, crmProjectTotal: result.totalCount, selection: uri,
                 defaultCurrency: grailsApplication.config.crm.currency.default ?: 'EUR']
            }
        } catch (Exception e) {
            flash.error = e.message
            [crmProjectList : [], crmProjectTotal: 0, selection: uri,
             defaultCurrency: grailsApplication.config.crm.currency.default ?: 'EUR']
        }
    }

    def clearQuery() {
        WebUtils.setTenantData(request, 'crmProjectQuery', null)
        redirect(action: "index")
    }

    private void bindDate(def target, String property, String value, TimeZone timezone = null) {
        if (value) {
            try {
                target[property] = DateUtils.parseSqlDate(value, timezone)
            } catch (Exception e) {
                def entityName = message(code: 'crmProject.label', default: 'Project')
                def propertyName = message(code: 'crmProject.' + property + '.label', default: property)
                target.errors.rejectValue(property, 'default.invalid.date.message', [propertyName, entityName, value.toString(), e.message].toArray(), "Invalid date: {2}")
            }
        } else {
            target[property] = null
        }
    }

    def show() {
        def crmProject = CrmProject.findByIdAndTenantId(params.id, TenantUtils.tenant)
        if (!crmProject) {
            flash.error = message(code: 'crmProject.not.found.message', args: [message(code: 'crmProject.label', default: 'Project'), params.id])
            redirect action: 'list'
            return
        }
        def children = crmProject.children ?: []
        def metadata = [statusList: crmProjectService.listProjectStatus(null)]
        def items = crmProject.items ?: []

        [crmProject: crmProject, items: items.sort { it.orderIndex }, children: children.sort { it.number },
         reference : crmProject.reference, customer: crmProject.customer, contact: crmProject.contact,
         metadata  : metadata, roles: crmProject.roles.sort { it.type.orderIndex }, selection: params.getSelectionURI()]
    }

    private List getVatOptions() {
        getVatList().collect {
            [label: "${it}%", value: (it / 100).doubleValue()]
        }
    }

    private List<Number> getVatList() {
        grailsApplication.config.crm.currency.vat.list ?: [0]
    }

    @Transactional
    def create() {
        def crmTenant = crmSecurityService.getCurrentTenant()
        def tenant = crmTenant.id
        def currentUser = crmSecurityService.getUserInfo()
        def crmProject = new CrmProject()
        if (!params.date1) {
            params.date1 = formatDate(type: 'date', date: new Date())
        }
        if (!params.currency) {
            params.currency = crmTenant.getOption('currency') ?: (grailsApplication.config.crm.currency.default ?: 'EUR')
        }
        def metadata = [:]
        metadata.statusList = CrmProjectStatus.findAllByEnabledAndTenantId(true, tenant)
        metadata.typeList = CrmProjectType.findAllByEnabledAndTenantId(true, tenant)
        metadata.categoryList = CrmProjectCategory.findAllByEnabledAndTenantId(true, tenant)
        metadata.userList = crmSecurityService.getTenantUsers()
        metadata.currencyList = ['SEK', 'EUR', 'GBP', 'USD']
        metadata.vatList = getVatOptions()

        switch (request.method) {
            case 'GET':
                bindData(crmProject, params, [include: CrmProject.BIND_WHITELIST, exclude: ['date1', 'date2', 'date3', 'date4']])
                bindDate(crmProject, 'date1', params.date1, currentUser?.timezone)
                bindDate(crmProject, 'date2', params.date2, currentUser?.timezone)
                bindDate(crmProject, 'date3', params.date3, currentUser?.timezone)
                bindDate(crmProject, 'date4', params.date4, currentUser?.timezone)
                if (params.reference) {
                    crmProject.setReference(params.reference)
                }
                crmProject.tenantId = tenant
                if (!crmProject.username) {
                    crmProject.username = currentUser?.username
                }
                def customer = crmProject.customer
                def contact = null
                if (!customer) {
                    def customerId = params.long('customer')
                    if (customerId) {
                        customer = crmContactService.getContact(customerId)
                    }
                }
                def items = crmProject.items ?: []
                return [crmProject: crmProject, items: items.sort { it.orderIndex },
                        metadata  : metadata, user: currentUser,
                        reference : crmProject.reference, customer: customer, contact: contact]
            case 'POST':
                def customer
                def contact
                def ok = false
                try {
                    crmProject = crmProjectService.save(crmProject, params)
                    customer = crmProject.customer
                    contact = crmProject.contact
                    ok = true
                } catch (CrmValidationException e) {
                    crmProject = e[0]
                    customer = e[1]
                    contact = e[2]
                }

                if (ok) {
                    event(for: "crmProject", topic: "created", fork: true, data: [id: crmProject.id, tenant: crmProject.tenantId, user: currentUser?.username])
                    flash.success = message(code: 'crmProject.created.message', args: [message(code: 'crmProject.label', default: 'Project'), crmProject.toString()])
                    redirect action: 'show', id: crmProject.id
                } else {
                    def items = crmProject.items ?: []
                    def user = crmSecurityService.getUserInfo(params.username ?: crmProject.username)
                    render view: 'create', model: [crmProject: crmProject, items: items.sort { it.orderIndex },
                                                   metadata  : metadata, user: user,
                                                   reference : crmProject.reference, customer: customer, contact: contact]
                }
                break
        }
    }

    @Transactional
    def edit() {
        def crmTenant = crmSecurityService.getCurrentTenant()
        def tenant = crmTenant.id
        def currentUser = crmSecurityService.getUserInfo()
        def crmProject = CrmProject.findByIdAndTenantId(params.id, crmTenant.id)
        if (!crmProject) {
            flash.error = message(code: 'crmProject.not.found.message', args: [message(code: 'crmProject.label', default: 'Project'), params.id])
            redirect action: 'index'
            return
        }

        if (request.post) {
            if (params.int('version') != null && crmProject.version > params.int('version')) {
                crmProject.errors.rejectValue("version", "crmProject.optimistic.locking.failure",
                        [message(code: 'crmProject.label', default: 'Project')] as Object[],
                        "Another user has updated this project while you were editing")
            } else {
                def ok = false
                try {
                    crmProject = crmProjectService.save(crmProject, params)
                    ok = !crmProject.hasErrors()
                } catch (CrmValidationException e) {
                    crmProject = (CrmProject) e[0]
                } catch (Exception e) {
                    // Re-attach object to this Hibernate session to avoid problems with uninitialized associations.
                    if (!crmProject.isAttached()) {
                        crmProject.discard()
                        crmProject.attach()
                    }
                    log.warn("Failed to save crmProject@$id", e)
                    flash.error = e.message
                }

                if (ok) {
                    event(for: "crmProject", topic: "updated", fork: true, data: [id: crmProject.id, tenant: crmProject.tenantId, user: currentUser?.username])
                    flash.success = message(code: 'crmProject.updated.message', args: [message(code: 'crmProject.label', default: 'Project'), crmProject.toString()])
                    redirect action: 'show', id: crmProject.id
                    return
                }
            }
        }

        def metadata = [:]
        metadata.statusList = CrmProjectStatus.findAllByEnabledAndTenantId(true, tenant)
        metadata.typeList = CrmProjectType.findAllByEnabledAndTenantId(true, tenant)
        metadata.categoryList = CrmProjectCategory.findAllByEnabledAndTenantId(true, tenant)
        metadata.userList = crmSecurityService.getTenantUsers()
        metadata.currencyList = ['SEK', 'EUR', 'GBP', 'USD']
        metadata.vatList = getVatOptions()
        metadata.vat = grailsApplication.config.crm.currency.vat.default ?: 0
        def items = crmProject.items ?: []
        [crmProject: crmProject, items: items.sort { it.orderIndex },
         customer  : crmProject.customer, reference: crmProject.reference,
         metadata  : metadata, user: currentUser]
    }

    @Transactional
    def delete(Long id) {
        def crmProject = CrmProject.findByIdAndTenantId(id, TenantUtils.tenant)
        if (!crmProject) {
            flash.error = message(code: 'crmProject.not.found.message', args: [message(code: 'crmProject.label', default: 'Project'), id])
            redirect action: 'index'
            return
        }

        def children = CrmProject.countByParent(crmProject)
        if (children) {
            flash.error = message(code: 'crmProject.delete.childrenExists.message', args: [message(code: 'crmProject.label', default: 'Project'), id, children])
            redirect action: 'show', id: id, fragment: 'children'
            return
        }

        try {
            def parentId = crmProject.parentId
            def tombstone = crmProjectService.deleteProject(crmProject)
            flash.warning = message(code: 'crmProject.deleted.message', args: [message(code: 'crmProject.label', default: 'Project'), tombstone])
            if (parentId) {
                redirect action: 'show', id: parentId, fragment: 'children'
            } else {
                redirect action: 'index'
            }
        } catch (DataIntegrityViolationException e) {
            flash.error = message(code: 'crmProject.not.deleted.message', args: [message(code: 'crmProject.label', default: 'Project'), params.id])
            redirect action: 'show', id: params.id
        }
    }

    @Transactional
    def addRole(Long id, String type, String description) {
        def crmProject = crmProjectService.getProject(id)
        if (!crmProject) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }
        if (request.post) {
            def related = params.related
            def relatedContact
            if (related?.isNumber()) {
                relatedContact = crmContactService.getContact(Long.valueOf(related))
                if (!relatedContact) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND)
                    return
                }
                if (relatedContact.tenantId != crmProject.tenantId) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN)
                    return
                }
            } else if (related) {
                if (related.startsWith('@')) {
                    relatedContact = crmContactService.createPerson(firstName: related[1..-1], true)
                } else if (related.endsWith('@')) {
                    relatedContact = crmContactService.createPerson(firstName: related[0..-2], true)
                } else {
                    relatedContact = crmContactService.createCompany(name: related, true)
                }
            }

            if (relatedContact) {
                def roleInstance = crmProjectService.addRole(crmProject, relatedContact, type, description)
                flash.success = "${roleInstance} skapad"
            } else {
                flash.warning = "No role created"
            }
            redirect(action: 'show', id: id, fragment: "roles")
        } else {
            def role = new CrmProjectRole(project: crmProject)
            render template: 'addRole', model: [bean     : role, crmProject: crmProject,
                                                roleTypes: crmProjectService.listProjectRoleType(null)]
        }
    }

    @Transactional
    def editRole(Long id, Long r) {
        def crmProject = crmProjectService.getProject(id)
        def roleInstance = CrmProjectRole.get(r)
        if (!(roleInstance && crmProject)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }
        if (roleInstance.projectId != crmProject.id) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN)
            return
        }
        if (request.post) {
            CrmProjectRole.withTransaction {
                bindData(roleInstance, params, [include: ['type', 'description']])
                roleInstance.save(flush: true)
            }
            redirect(action: 'show', id: id, fragment: "roles")
        } else {
            render template: 'editRole', model: [crmProject: crmProject, bean: roleInstance,
                                                 roleTypes : crmProjectService.listProjectRoleType(null)]
        }
    }

    @Transactional
    def deleteRole(Long id, Long r) {
        def crmProject = crmProjectService.getProject(id)
        def roleInstance = CrmProjectRole.get(r)
        if (!(roleInstance && crmProject)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }
        if (roleInstance.projectId != crmProject.id) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN)
            return
        }
        def tombstone = roleInstance.toString()
        def msg = message(code: 'crmProjectRole.deleted.message', default: 'Role {1} deleted', args: ['Role', tombstone])

        roleInstance.delete(flush: true)

        flash.warning = msg

        if (request.xhr) {
            def result = [id: id, r: r, message: msg, role: tombstone]
            render result as JSON
        } else {
            redirect(action: 'show', id: id, fragment: "roles")
        }
    }

    @Transactional
    def changeStatus(Long id, String status) {
        def crmProject = crmProjectService.getProject(id)
        if (!crmProject) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }
        def newStatus = crmProjectService.getProjectStatus(status)
        if (!newStatus) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }

        crmProject.status = newStatus
        crmProject.save()

        flash.success = "Status updated to $newStatus"

        if (request.xhr) {
            def result = crmProject.dao
            render result as JSON
        } else {
            redirect(action: 'show', id: id)
        }
    }

    def autocompleteProject(Long id, String q) {
        def result = CrmProject.createCriteria().list(max: 100) {
            eq('tenantId', TenantUtils.tenant)
            isNull('parent')
            if (id) {
                ne('id', id)
            }
            if (q) {
                or {
                    eq('number', q)
                    ilike('name', SearchUtils.wildcard(q))
                }
            }
        }.collect {
            [it.name, it.id, it.number, it.status.toString(), it.customer?.toString(), it.contact?.toString()]
        }
        WebUtils.shortCache(response)
        render result as JSON
    }

    def autocompleteContact() {
        if (params.parent) {
            if (pluginManager.hasGrailsPlugin('crmContactLite')) {
                params.parent = params.long('parent')
            } else {
                params.related = params.parent
                params.parent = null
            }
        }
        if (params.related) {
            params.related = params.long('related')
        }
        if (params.company) {
            params.company = params.boolean('company')
        }
        if (params.person) {
            params.person = params.boolean('person')
        }
        def result = crmContactService.list(params, [max: 100]).collect {
            def contact = it.primaryContact ?: it.parent
            [it.fullName, it.id, it.toString(), contact?.id, contact?.toString(), it.firstName, it.lastName, it.address.toString(), it.telephone, it.email]
        }
        WebUtils.shortCache(response)
        render result as JSON
    }

    def autocompleteUsername() {
        def query = params.q?.toLowerCase()
        def list = crmSecurityService.getTenantUsers().findAll { user ->
            if (query) {
                return user.name.toLowerCase().contains(query) || user.username.toLowerCase().contains(query)
            }
            return true
        }.collect { user ->
            [id: user.username, text: user.name]
        }
        def result = [q: params.q, timestamp: System.currentTimeMillis(), length: list.size(), more: false, results: list]
        WebUtils.defaultCache(response)
        render result as JSON
    }

    def autocompleteReference(Long id, String q) {
        def user = crmSecurityService.getUserInfo()
        def result = event(for: 'crmProject', topic: 'autocomplete',
                data: [tenant  : TenantUtils.tenant, id: id, property: 'ref', query: q,
                       username: user.username, locale: request.locale]).waitFor(10000)?.values?.flatten() ?: []
        result = result.collect { [it.text, it.id] }.sort { it[0] }
        WebUtils.shortCache(response)
        render result as JSON
    }

    def createFavorite(Long id) {
        def crmProject = crmProjectService.getProject(id)
        if (!crmProject) {
            flash.error = message(code: 'crmProject.not.found.message', args: [message(code: 'crmProject.label', default: 'Opportunity'), id])
            redirect action: 'index'
            return
        }
        userTagService.tag(crmProject, grailsApplication.config.crm.tag.favorite, crmSecurityService.currentUser?.username, TenantUtils.tenant)

        redirect(action: 'show', id: params.id)
    }

    def deleteFavorite(Long id) {
        def crmProject = crmProjectService.getProject(id)
        if (!crmProject) {
            flash.error = message(code: 'crmProject.not.found.message', args: [message(code: 'crmProject.label', default: 'Opportunity'), id])
            redirect action: 'index'
            return
        }
        userTagService.untag(crmProject, grailsApplication.config.crm.tag.favorite, crmSecurityService.currentUser?.username, TenantUtils.tenant)
        redirect(action: 'show', id: params.id)
    }

    def export() {
        def user = crmSecurityService.getUserInfo()
        def ns = params.ns ?: 'crmProject'
        if (request.post) {
            def filename = message(code: 'crmProject.label', default: 'Project')
            try {
                def timeout = (grailsApplication.config.crm.project.export.timeout ?: 60) * 1000
                def topic = params.topic ?: 'export'
                def result = event(for: ns, topic: topic,
                        data: params + [user: user, tenant: TenantUtils.tenant, locale: request.locale, filename: filename]).waitFor(timeout)?.value
                if (result?.file) {
                    try {
                        WebUtils.inlineHeaders(response, result.contentType, result.filename ?: ns)
                        WebUtils.renderFile(response, result.file)
                    } finally {
                        result.file.delete()
                    }
                    return null // Success
                } else {
                    flash.warning = message(code: 'crmProject.export.nothing.message', default: 'Nothing was exported')
                }
            } catch (TimeoutException te) {
                flash.error = message(code: 'crmProject.export.timeout.message', default: 'Export did not complete')
            } catch (Exception e) {
                log.error("Export event throwed an exception", e)
                flash.error = message(code: 'crmProject.export.error.message', default: 'Export failed due to an error', args: [e.message])
            }
            redirect(action: "index")
        } else {
            def uri = params.getSelectionURI()
            def layouts = event(for: ns, topic: (params.topic ?: 'exportLayout'),
                    data: [tenant: TenantUtils.tenant, username: user.username, uri: uri, locale: request.locale]).waitFor(10000)?.values?.flatten()
            [layouts: layouts, selection: uri]
        }
    }
}
