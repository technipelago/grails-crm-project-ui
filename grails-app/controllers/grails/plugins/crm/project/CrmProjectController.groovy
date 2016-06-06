package grails.plugins.crm.project

import grails.converters.JSON
import grails.plugins.crm.contact.CrmContact
import grails.plugins.crm.core.DateUtils
import grails.plugins.crm.core.TenantUtils
import grails.plugins.crm.core.WebUtils
import grails.plugins.crm.core.CrmValidationException
import grails.transaction.Transactional

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
                [crmProjectList: result, crmProjectTotal: result.totalCount, selection: uri]
            }
        } catch (Exception e) {
            flash.error = e.message
            [crmProjectList: [], crmProjectTotal: 0, selection: uri]
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
        def metadata = [statusList: crmProjectService.listProjectStatus(null)]
        [crmProject: crmProject,
         reference: crmProject.reference, customer: crmProject.customer, contact: crmProject.contact,
         metadata       : metadata, roles: crmProject.roles.sort {
            it.type.orderIndex
        }, selection    : params.getSelectionURI()]
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
        def reference = params.reference ? crmCoreService.getReference(params.reference) : null
        def metadata = [:]
        metadata.statusList = CrmProjectStatus.findAllByEnabledAndTenantId(true, tenant)
        metadata.userList = crmSecurityService.getTenantUsers()

        switch (request.method) {
            case 'GET':
                bindDate(crmProject, 'date1', params.remove('date1'), currentUser?.timezone)
                bindDate(crmProject, 'date2', params.remove('date2'), currentUser?.timezone)
                bindDate(crmProject, 'date3', params.remove('date3'), currentUser?.timezone)
                bindDate(crmProject, 'date4', params.remove('date4'), currentUser?.timezone)
                bindData(crmProject, params, [include: CrmProject.BIND_WHITELIST])
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
                return [crmProject: crmProject, metadata: metadata, user: currentUser,
                        reference: reference, customer: customer, contact: contact]
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
                    event(for: "crmProject", topic: "created", fork: false, data: [id: crmProject.id, tenant: crmProject.tenantId, user: currentUser?.username])
                    flash.success = message(code: 'crmProject.created.message', args: [message(code: 'crmProject.label', default: 'Project'), crmProject.toString()])
                    redirect action: 'show', id: crmProject.id
                } else {
                    def user = crmSecurityService.getUserInfo(params.username ?: crmProject.username)
                    render view: 'create', model: [crmProject: crmProject, metadata: metadata, user: user,
                                                   reference: reference, customer: customer, contact: contact]
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
        def metadata = [:]
        metadata.statusList = CrmProjectStatus.findAllByEnabledAndTenantId(true, tenant)
        metadata.userList = crmSecurityService.getTenantUsers()

        switch (request.method) {
            case 'GET':
                return [crmProject: crmProject, metadata: metadata, user: currentUser]
            case 'POST':
                def ok = true
                CrmProject.withTransaction { tx ->
                    //crmProjectService.fixCustomerParams(params)
                    bindDate(crmProject, 'date1', params.remove('date1'), currentUser?.timezone)
                    bindDate(crmProject, 'date2', params.remove('date2'), currentUser?.timezone)
                    bindDate(crmProject, 'date3', params.remove('date3'), currentUser?.timezone)
                    bindDate(crmProject, 'date4', params.remove('date4'), currentUser?.timezone)
                    bindData(crmProject, params)
                    if (!crmProject.save(flush: true)) {
                        ok = false
                        tx.setRollbackOnly()
                    }
                }

                if (ok) {
                    event(for: "crmProject", topic: "updated", fork: false, data: [id: crmProject.id, tenant: crmProject.tenantId, user: currentUser?.username])
                    flash.success = message(code: 'crmProject.updated.message', args: [message(code: 'crmProject.label', default: 'Project'), crmProject.toString()])
                    redirect action: 'show', id: crmProject.id
                } else {
                    def user = crmSecurityService.getUserInfo(params.username ?: crmProject.username)
                    render view: 'edit', model: [crmProject: crmProject, metadata: metadata, user: user]
                }
                break
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
                                                 roleTypes      : crmProjectService.listProjectRoleType(null)]
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

    def autocompleteContact() {
        if (params.parent) {
            if(pluginManager.hasGrailsPlugin('crmContactLite')) {
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
