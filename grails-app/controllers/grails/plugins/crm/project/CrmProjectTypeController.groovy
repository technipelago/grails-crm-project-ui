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
class CrmProjectTypeController {

    static allowedMethods = [create: ['GET', 'POST'], edit: ['GET', 'POST'], delete: 'POST']

    def selectionService
    def crmProjectService

    def domainClass = CrmProjectType

    def index() {
        redirect action: 'list', params: params
    }

    def list() {
        def baseURI = new URI('gorm://crmProjectType/list')
        def query = params.getSelectionQuery()
        def uri

        switch (request.method) {
            case 'GET':
                uri = params.getSelectionURI() ?: selectionService.addQuery(baseURI, query)
                break
            case 'POST':
                uri = selectionService.addQuery(baseURI, query)
                grails.plugins.crm.core.WebUtils.setTenantData(request, 'crmProjectTypeQuery', query)
                break
        }

        params.max = Math.min(params.max ? params.int('max') : 20, 100)

        try {
            def result = selectionService.select(uri, params)
            [crmProjectTypeList: result, crmProjectTypeTotal: result.totalCount, selection: uri]
        } catch (Exception e) {
            flash.error = e.message
            [crmProjectTypeList: [], crmProjectTypeTotal: 0, selection: uri]
        }
    }

    def create() {
        def crmProjectType = crmProjectService.createProjectType(params)
        switch (request.method) {
            case 'GET':
                return [crmProjectType: crmProjectType]
            case 'POST':
                if (!crmProjectType.save(flush: true)) {
                    render view: 'create', model: [crmProjectType: crmProjectType]
                    return
                }
                flash.success = message(code: 'crmProjectType.created.message', args: [message(code: 'crmProjectType.label', default: 'Status'), crmProjectType.toString()])
                redirect action: 'list'
                break
        }
    }

    def edit() {
        switch (request.method) {
            case 'GET':
                def crmProjectType = domainClass.get(params.id)
                if (!crmProjectType) {
                    flash.error = message(code: 'crmProjectType.not.found.message', args: [message(code: 'crmProjectType.label', default: 'Status'), params.id])
                    redirect action: 'list'
                    return
                }

                return [crmProjectType: crmProjectType]
            case 'POST':
                def crmProjectType = domainClass.get(params.id)
                if (!crmProjectType) {
                    flash.error = message(code: 'crmProjectType.not.found.message', args: [message(code: 'crmProjectType.label', default: 'Status'), params.id])
                    redirect action: 'list'
                    return
                }

                if (params.version) {
                    def version = params.version.toLong()
                    if (crmProjectType.version > version) {
                        crmProjectType.errors.rejectValue('version', 'crmProjectType.optimistic.locking.failure',
                                [message(code: 'crmProjectType.label', default: 'Status')] as Object[],
                                "Another user has updated this Status while you were editing")
                        render view: 'edit', model: [crmProjectType: crmProjectType]
                        return
                    }
                }

                crmProjectType.properties = params

                if (!crmProjectType.save(flush: true)) {
                    render view: 'edit', model: [crmProjectType: crmProjectType]
                    return
                }

                flash.success = message(code: 'crmProjectType.updated.message', args: [message(code: 'crmProjectType.label', default: 'Status'), crmProjectType.toString()])
                redirect action: 'list'
                break
        }
    }

    def delete() {
        def crmProjectType = domainClass.get(params.id)
        if (!crmProjectType) {
            flash.error = message(code: 'crmProjectType.not.found.message', args: [message(code: 'crmProjectType.label', default: 'Status'), params.id])
            redirect action: 'list'
            return
        }

        if (isInUse(crmProjectType)) {
            render view: 'edit', model: [crmProjectType: crmProjectType]
            return
        }

        try {
            def tombstone = crmProjectType.toString()
            crmProjectType.delete(flush: true)
            flash.warning = message(code: 'crmProjectType.deleted.message', args: [message(code: 'crmProjectType.label', default: 'Status'), tombstone])
            redirect action: 'list'
        }
        catch (DataIntegrityViolationException e) {
            flash.error = message(code: 'crmProjectType.not.deleted.message', args: [message(code: 'crmProjectType.label', default: 'Status'), params.id])
            redirect action: 'edit', id: params.id
        }
    }

    private boolean isInUse(CrmProjectType status) {
        def count = CrmProject.countByStatus(status)
        def rval = false
        if (count) {
            flash.error = message(code: "crmProjectType.delete.error.reference", args:
                    [message(code: 'crmProjectType.label', default: ' Status'),
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
