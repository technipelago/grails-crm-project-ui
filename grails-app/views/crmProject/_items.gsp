<g:set var="currencyCode" value="${bean.currency ?: 'EUR'}"/>
<g:set var="budgetTotal" value="${0}"/>
<g:set var="actualTotal" value="${0}"/>

<table class="table table-striped">
    <thead>
    <tr>
        <th><g:message code="crmProjectItem.orderIndex.label"/></th>
        <th><g:message code="crmProjectItem.name.label"/></th>
        <th class="money"><g:message code="crmProjectItem.budget.label"/></th>
        <th class="money"><g:message code="crmProjectItem.actual.label"/></th>
        <th class="money"><g:message code="crmProjectItem.diff.label"/></th>
    </tr>
    </thead>
    <tbody>
    <g:each in="${list}" var="item">
        <tr>
            <td style="width: 5%;">
                <g:fieldValue bean="${item}" field="orderIndex"/>
            </td>
            <td style="width: 45%;">
                <g:fieldValue bean="${item}" field="name"/>
            </td>
            <td class="money nowrap">
                <g:formatNumber number="${item.budget}" maxFractionDigits="0"
                                type="currency" currencyCode="${currencyCode}"/>
            </td>

            <td class="money nowrap">
                <g:formatNumber number="${item.actual}" maxFractionDigits="0"
                                type="currency" currencyCode="${currencyCode}"/>
            </td>

            <td class="money nowrap">
                <g:formatNumber number="${item.diff}" maxFractionDigits="0"
                                type="currency" currencyCode="${currencyCode}"/>
            </td>
        </tr>
        <g:set var="budgetTotal" value="${budgetTotal + item.budget}"/>
        <g:set var="actualTotal" value="${actualTotal + item.actual}"/>
    </g:each>
    </tbody>
    <tfoot>
    <tr>
        <th colspan="2"></th>
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
