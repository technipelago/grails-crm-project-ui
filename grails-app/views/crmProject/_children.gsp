<g:set var="currencyCode" value="${bean.currency ?: 'EUR'}"/>
<g:set var="budgetTotal" value="${0}"/>
<g:set var="actualTotal" value="${0}"/>

<table class="table table-striped">
    <thead>
    <tr>
        <th><g:message code="crmProject.number.label"/></th>
        <th><g:message code="crmProject.name.label"/></th>
        <th><g:message code="crmProject.status.label"/></th>
        <th><g:message code="crmProject.date1.label"/></th>
        <th><g:message code="crmProject.date2.label"/></th>
        <th class="money"><g:message code="crmProject.budget.label" default="Budget"/></th>
        <th class="money"><g:message code="crmProject.actual.label" default="Actual"/></th>
        <th class="money"><g:message code="crmProject.diff.label" default="Diff"/></th>
    </tr>
    </thead>
    <tbody>
    <g:each in="${list}" var="crmProject">
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
                <g:formatNumber number="${crmProject.budget}" maxFractionDigits="0"
                                type="currency" currencyCode="${crmProject.currency ?: 'EUR'}"/>
            </td>
            <td class="money nowrap">
                <g:formatNumber number="${crmProject.actual}" maxFractionDigits="0"
                                type="currency" currencyCode="${crmProject.currency ?: 'EUR'}"/>
            </td>
            <td class="money nowrap">
                <g:formatNumber number="${crmProject.diff}" maxFractionDigits="0"
                                type="currency" currencyCode="${crmProject.currency ?: 'EUR'}"/>
            </td>
        </tr>
        <g:set var="budgetTotal" value="${budgetTotal + crmProject.budget}"/>
        <g:set var="actualTotal" value="${actualTotal + crmProject.actual}"/>
    </g:each>
    </tbody>
    <tfoot>
    <tr>
        <th colspan="5"></th>
        <th class="money nowrap"><g:formatNumber number="${budgetTotal}" maxFractionDigits="0"
                                        type="currency" currencyCode="${currencyCode}"/></th>
        <th class="money nowrap"><g:formatNumber number="${actualTotal}" maxFractionDigits="0"
                                        type="currency" currencyCode="${currencyCode}"/></th>
        <th class="money nowrap ${(budgetTotal - actualTotal) < 0 ? 'negative' : 'positive'}">
            <g:formatNumber number="${budgetTotal - actualTotal}" maxFractionDigits="0"
                                        type="currency" currencyCode="${currencyCode}"/>
        </th>
    </tr>
    </tfoot>
</table>

<div class="form-actions btn-toolbar">
    <crm:button type="link" group="true" action="create" params="${['parent.id': bean.id]}"
                visual="success" icon="icon-file icon-white"
                label="crmProject.button.create.child.label"
                title="crmProject.button.create.child.help"
                permission="crmProject:create">
    </crm:button>
</div>
