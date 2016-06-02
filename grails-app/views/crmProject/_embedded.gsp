<table class="table table-striped">
    <thead>
    <tr>
        <th><g:message code="crmProject.name.label" default="Project"/></th>
        <th><g:message code="crmProject.customer.label" default="Contact"/></th>
        <th><g:message code="crmProjectRole.type.label" default="Role"/></th>
        <th><g:message code="crmProject.status.label" default="Status"/></th>
        <th><g:message code="crmProject.date2.label" default="Date 2"/></th>
    </tr>
    </thead>
    <tbody>
    <g:each in="${result}" var="roleInstance">
        <g:set var="project" value="${roleInstance.project}"/>
        <tr>

            <td>
                <g:link controller="crmProject" action="show" id="${project.id}" fragment="roles">
                    ${fieldValue(bean: project, field: "name")}
                </g:link>
            </td>

            <td>
                <g:link controller="crmProject" action="show" id="${project.id}" fragment="roles">
                    ${fieldValue(bean: roleInstance, field: "contact")}
                </g:link>
            </td>

            <td>

                ${fieldValue(bean: roleInstance, field: "type")}

            </td>

            <td>

                ${fieldValue(bean: project, field: "status")}

            </td>

            <td class="nowrap">

                <g:formatDate type="date" date="${project.date2}"/>

            </td>

        </tr>
    </g:each>
    </tbody>
</table>

<g:if test="${createParams}">
    <div class="form-actions btn-toolbar">
        <crm:button type="link" group="true" controller="crmProject" action="create" visual="success"
                    icon="icon-file icon-white"
                    label="crmProject.button.create.label"
                    title="crmProject.button.create.help"
                    permission="crmProject:create"
                    params="${createParams}">
        </crm:button>
    </div>
</g:if>