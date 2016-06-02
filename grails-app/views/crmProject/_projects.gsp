<table class="table table-striped">
    <thead>
    <tr>
        <th><g:message code="crmProject.customer.label" default="Customer"/></th>

        <g:sortableColumn property="name"
                          title="${message(code: 'crmProject.name.label', default: 'Name')}"/>

        <g:sortableColumn property="status.name"
                          title="${message(code: 'crmProject.status.label', default: 'Status')}"/>

        <g:sortableColumn property="date2"
                          title="${message(code: 'crmProject.date2.label', default: 'Order Date')}"/>

    </tr>
    </thead>
    <tbody>
    <g:each in="${result}" var="crmProject">
        <tr>

            <td>
                <g:link controller="crmProject" action="show" id="${crmProject.id}">
                    ${fieldValue(bean: crmProject, field: "customer")}
                </g:link>
            </td>

            <td>
                <g:link controller="crmProject" action="show" id="${crmProject.id}">
                    ${fieldValue(bean: crmProject, field: "name")}
                </g:link>
            </td>

            <td>

                ${fieldValue(bean: crmProject, field: "status")}

            </td>

            <td class="nowrap">

                <g:formatDate type="date" date="${crmProject.date2}"/>

            </td>


        </tr>
    </g:each>
    </tbody>
</table>

<div class="form-actions btn-toolbar">
    <crm:button type="link" group="true" controller="crmProject" action="create" visual="success"
                icon="icon-file icon-white"
                label="crmProject.button.create.label"
                title="crmProject.button.create.help"
                permission="crmProject:create"
                params="${createParams}">
    </crm:button>
</div>
