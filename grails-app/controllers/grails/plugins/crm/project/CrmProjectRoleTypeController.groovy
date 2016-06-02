/*
 * Copyright (c) 2012 Goran Ehrsson.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *  under the License.
 */
package grails.plugins.crm.project

import org.springframework.dao.DataIntegrityViolationException
import javax.servlet.http.HttpServletResponse

/**
 * This controller provides...
 *
 * @author Goran Ehrsson
 * @since 0.1
 */
class CrmProjectRoleTypeController {

    static allowedMethods = [create: ['GET', 'POST'], edit: ['GET', 'POST'], delete: 'POST']

    def selectionService
    def crmProjectService

    def domainClass = CrmProjectRoleType

    def index() {
        redirect action: 'list', params: params
    }

    def list() {
        def baseURI = new URI('gorm://crmProjectRoleType/list')
        def query = params.getSelectionQuery()
        def uri

        switch (request.method) {
            case 'GET':
                uri = params.getSelectionURI() ?: selectionService.addQuery(baseURI, query)
                break
            case 'POST':
                uri = selectionService.addQuery(baseURI, query)
                grails.plugins.crm.core.WebUtils.setTenantData(request, 'crmProjectRoleTypeQuery', query)
                break
        }

        params.max = Math.min(params.max ? params.int('max') : 20, 100)

        try {
            def result = selectionService.select(uri, params)
            [crmProjectRoleTypeList: result, crmProjectRoleTypeTotal: result.totalCount, selection: uri]
        } catch (Exception e) {
            flash.error = e.message
            [crmProjectRoleTypeList: [], crmProjectRoleTypeTotal: 0, selection: uri]
        }
    }

    def create() {
        def crmProjectRoleType = crmProjectService.createProjectRoleType(params)
        switch (request.method) {
            case 'GET':
                return [crmProjectRoleType: crmProjectRoleType]
            case 'POST':
                if (!crmProjectRoleType.save(flush: true)) {
                    render view: 'create', model: [crmProjectRoleType: crmProjectRoleType]
                    return
                }
                flash.success = message(code: 'crmProjectRoleType.created.message', args: [message(code: 'crmProjectRoleType.label', default: 'Status'), crmProjectRoleType.toString()])
                redirect action: 'list'
                break
        }
    }

    def edit() {
        switch (request.method) {
            case 'GET':
                def crmProjectRoleType = domainClass.get(params.id)
                if (!crmProjectRoleType) {
                    flash.error = message(code: 'crmProjectRoleType.not.found.message', args: [message(code: 'crmProjectRoleType.label', default: 'Status'), params.id])
                    redirect action: 'list'
                    return
                }

                return [crmProjectRoleType: crmProjectRoleType]
            case 'POST':
                def crmProjectRoleType = domainClass.get(params.id)
                if (!crmProjectRoleType) {
                    flash.error = message(code: 'crmProjectRoleType.not.found.message', args: [message(code: 'crmProjectRoleType.label', default: 'Status'), params.id])
                    redirect action: 'list'
                    return
                }

                if (params.version) {
                    def version = params.version.toLong()
                    if (crmProjectRoleType.version > version) {
                        crmProjectRoleType.errors.rejectValue('version', 'crmProjectRoleType.optimistic.locking.failure',
                                [message(code: 'crmProjectRoleType.label', default: 'Status')] as Object[],
                                "Another user has updated this Status while you were editing")
                        render view: 'edit', model: [crmProjectRoleType: crmProjectRoleType]
                        return
                    }
                }

                crmProjectRoleType.properties = params

                if (!crmProjectRoleType.save(flush: true)) {
                    render view: 'edit', model: [crmProjectRoleType: crmProjectRoleType]
                    return
                }

                flash.success = message(code: 'crmProjectRoleType.updated.message', args: [message(code: 'crmProjectRoleType.label', default: 'Status'), crmProjectRoleType.toString()])
                redirect action: 'list'
                break
        }
    }

    def delete() {
        def crmProjectRoleType = domainClass.get(params.id)
        if (!crmProjectRoleType) {
            flash.error = message(code: 'crmProjectRoleType.not.found.message', args: [message(code: 'crmProjectRoleType.label', default: 'Status'), params.id])
            redirect action: 'list'
            return
        }

        if (isInUse(crmProjectRoleType)) {
            render view: 'edit', model: [crmProjectRoleType: crmProjectRoleType]
            return
        }

        try {
            def tombstone = crmProjectRoleType.toString()
            crmProjectRoleType.delete(flush: true)
            flash.warning = message(code: 'crmProjectRoleType.deleted.message', args: [message(code: 'crmProjectRoleType.label', default: 'Status'), tombstone])
            redirect action: 'list'
        }
        catch (DataIntegrityViolationException e) {
            flash.error = message(code: 'crmProjectRoleType.not.deleted.message', args: [message(code: 'crmProjectRoleType.label', default: 'Status'), params.id])
            redirect action: 'edit', id: params.id
        }
    }

    private boolean isInUse(CrmProjectRoleType status) {
        def count = CrmProject.countByStatus(status)
        def rval = false
        if (count) {
            flash.error = message(code: "crmProjectRoleType.delete.error.reference", args:
                    [message(code: 'crmProjectRoleType.label', default: ' Status'),
                            message(code: 'crmProject.label', default: ' Project'), count],
                    default: "This {0} is used by {1} {2}")
            rval = true
        }

        return rval
    }

    def moveUp(Long id) {
        def target = domainClass.get(id)
        if (target) {
            def sort = target.orderIndex
            def prev = domainClass.createCriteria().list([sort: 'orderIndex', order: 'desc']) {
                lt('orderIndex', sort)
                maxResults 1
            }?.find { it }
            if (prev) {
                domainClass.withTransaction { tx ->
                    target.orderIndex = prev.orderIndex
                    prev.orderIndex = sort
                }
            }
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
        }
        redirect action: 'list'
    }

    def moveDown(Long id) {
        def target = domainClass.get(id)
        if (target) {
            def sort = target.orderIndex
            def next = domainClass.createCriteria().list([sort: 'orderIndex', order: 'asc']) {
                gt('orderIndex', sort)
                maxResults 1
            }?.find { it }
            if (next) {
                domainClass.withTransaction { tx ->
                    target.orderIndex = next.orderIndex
                    next.orderIndex = sort
                }
            }
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
        }
        redirect action: 'list'
    }
}
