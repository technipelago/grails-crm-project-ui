<table class="table table-striped">
    <thead>
    <tr>
        <th><g:message code="crmProject.number.label"/></th>
        <th><g:message code="crmProject.name.label"/></th>
        <th><g:message code="crmProject.status.label"/></th>
        <th><g:message code="crmProject.date1.label"/></th>
        <th><g:message code="crmProject.date2.label"/></th>
        <th class="money"><g:message code="crmProject.value.label" default="Value"/></th>
    </tr>
    </thead>
    <tbody>
    <g:each in="${children}" var="crmProject">
        <tr class="${crmProject.active ? '' : 'disabled'}">
            <td>
                <g:link controller="crmProject" action="show" id="${crmProject.id}">
                    <g:fieldValue bean="${crmProject}" field="number"/>
                </g:link>
            </td>
            <td>
                <g:link controller="crmProject" action="show" id="${crmProject.id}">
                    <g:fieldValue bean="${crmProject}" field="name"/>
                </g:link>
            </td>

            <td>
                <g:fieldValue bean="${crmProject}" field="status"/>
            </td>

            <td class="nowrap">
                <g:formatDate type="date" date="${crmProject.date1}"/>
            </td>

            <td class="nowrap">
                <g:formatDate type="date" date="${crmProject.date2}"/>
            </td>
            <td class="money nowrap">
                <g:formatNumber number="${crmProject.value}" maxFractionDigits="0"
                                type="currency" currencyCode="${crmProject.currency ?: 'EUR'}"/>
            </td>
        </tr>
    </g:each>
    </tbody>
</table>

<div class="form-actions btn-toolbar">
    <crm:button type="link" group="true" action="create" visual="success"
                icon="icon-file icon-white"
                label="crmProject.button.create.label"
                title="crmProject.button.create.help"
                permission="crmProject:create">
        <g:unless test="${bean.parent}">
            <button class="btn btn-success dropdown-toggle" data-toggle="dropdown">
                <span class="caret"></span>
            </button>
            <ul class="dropdown-menu">
                <li>
                    <g:link action="create" params="${['parent.id': bean.id]}">
                        <g:message code="crmProject.button.create.sub.label" default="New sub-project"/>
                    </g:link>
                </li>
            </ul>
        </g:unless>
    </crm:button>
</div>
