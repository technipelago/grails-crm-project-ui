<%@ page import="grails.plugins.crm.project.CrmProject" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmProject.label', default: 'Project')}"/>
    <title><g:message code="crmProject.create.title" args="[entityName, crmProject]"/></title>
    <r:require modules="datepicker,autocomplete"/>
    <r:script>
    $(document).ready(function() {

        <crm:datepicker selector=".date"/>

        $("input[name='customer.name']").autocomplete("${createLink(action: 'autocompleteContact', params: [company: true])}", {
            remoteDataType: 'json',
            preventDefaultReturn: true,
            minChars: 1,
            selectFirst: true,
            queryParamName: 'name',
            useCache: false,
            filter: false,
            onItemSelect: function(item) {
                console.log('item', item.data);
                var id = item.data[0];
                var name = item.data[1];
                $("input[name='customer.id']").val(id);
                $("input[name='customer.name']").val(name);
                $("header h1 small").text(name);
                var ac = $("input[name='contact.name']").data('autocompleter');
                if(ac) {
                    ac.setExtraParam('parent', id);
                    ac.cacheFlush();
                }
            },
            onNoMatch: function() {
                $("input[name='customer.id']").val('');
                $("header h1 small").text($("input[name='customer.name']").val());
                var ac = $("input[name='contact.name']").data('autocompleter');
                if(ac) {
                    ac.setExtraParam('parent', '');
                    ac.cacheFlush();
                }
            }
        });

        $("input[name='contact.name']").autocomplete("${createLink(action: 'autocompleteContact', params: [person: true])}", {
            remoteDataType: 'json',
            preventDefaultReturn: true,
            minChars: 1,
            /*selectFirst: true,*/
            queryParamName: 'name',
            useCache: false,
            filter: false,
            extraParams: {},
            onItemSelect: function(item) {
                $("input[name='contact.id']").val(item.data[0]);
                $("input[name='contact.name']").val(item.data[1]);
            },
            onNoMatch: function() {
                $("input[name='contact.id']").val('');
            }
        });

        // Parent project.
        $("input[name='parent.name']").autocomplete("${createLink(controller: 'crmProject', action: 'autocompleteProject')}", {
            remoteDataType: 'json',
            preventDefaultReturn: true,
            minChars: 1,
            selectFirst: true,
            useCache: false,
            filter: false,
            extraParams: { id: "${crmProject.id}"},
            onItemSelect: function(item) {
                $("input[name='parent.id']").val(item.data[0]);
            },
            onNoMatch: function() {
                $("input[name='parent.id']").val('');
            }
        });

        // Reference.
        $("input[name='referenceName']").autocomplete("${createLink(controller: 'crmProject', action: 'autocompleteReference')}", {
            remoteDataType: 'json',
            preventDefaultReturn: true,
            minChars: 1,
            selectFirst: true,
            useCache: false,
            filter: false,
            extraParams: { id: "${crmProject.id}"},
            onItemSelect: function(item) {
                $("input[name='reference']").val(item.data[0]);
            },
            onNoMatch: function() {
                $("input[name='reference']").val('');
            }
        });

        $('a[data-toggle="tab"]').on('shown', function (ev) {
            //ev.target // activated tab
            //ev.relatedTarget // previous tab
            $(ev.target.hash + ' input:visible:first').focus();
        });
    });
    </r:script>
</head>

<body>

<crm:header title="crmProject.create.title" subtitle="${reference ?: customer}"
            args="[entityName, crmProject, reference, customer]"/>

<g:hasErrors bean="${crmProject}">
    <crm:alert class="alert-error">
        <ul>
            <g:eachError bean="${crmProject}" var="error">
                <li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message
                        error="${error}"/></li>
            </g:eachError>
        </ul>
    </crm:alert>
</g:hasErrors>

<g:form action="create">

    <f:with bean="crmProject">

        <div class="tabbable">
            <ul class="nav nav-tabs">
                <li class="active"><a href="#main" data-toggle="tab"><g:message
                        code="crmProject.tab.main.label"/></a>
                </li>
                <li><a href="#items" data-toggle="tab" accesskey="b"><g:message
                        code="crmProject.tab.budget.label"/></a></li>
                <li><a href="#desc" data-toggle="tab" accesskey="d"><g:message
                        code="crmProject.tab.desc.label"/></a></li>

            </ul>

            <div class="tab-content">
                <div class="tab-pane active" id="main">
                    <div class="row-fluid">


                        <div class="span3">
                            <div class="row-fluid">
                                <div class="control-group">
                                    <label class="control-label">
                                        <g:message code="crmProject.name.label"/>
                                    </label>

                                    <div class="controls">
                                        <g:textField name="name" value="${crmProject.name}" class="span12" autofocus=""/>
                                    </div>
                                </div>

                                <div class="control-group">
                                    <label class="control-label">
                                        <g:message code="crmProject.number.label"/>
                                    </label>

                                    <div class="controls">
                                        <g:textField name="number" value="${crmProject.number}" class="span8"/>
                                    </div>
                                </div>

                                <div class="control-group">
                                    <label class="control-label">
                                        <g:message code="crmProject.parent.label"/>
                                    </label>
                                    <div class="controls">
                                        <input type="hidden" name="parent.id" value="${crmProject.parentId}"/>
                                        <g:textField name="parent.name" value="${crmProject.parent?.name}" class="span12" autocomplete="off"/>
                                    </div>
                                </div>

                                <div class="control-group">
                                    <label class="control-label">
                                        <g:message code="crmProject.ref.label"/>
                                    </label>
                                    <div class="controls">
                                        <input type="hidden" name="reference" value="${crmProject.ref}"/>
                                        <g:textField name="referenceName" value="${reference}" class="span12" autocomplete="off"/>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="span3">
                            <div class="row-fluid">
                                <div class="control-group">
                                    <label class="control-label"><g:message code="crmProject.customer.label"/></label>
                                    <div class="controls">
                                        <g:textField name="customer.name" value="${customer?.name}"
                                                     autocomplete="off" class="span12"/>
                                        <g:hiddenField name="customer.id" value="${customer?.id}"/>
                                    </div>
                                </div>
                                <div class="control-group">
                                    <label class="control-label"><g:message code="crmProject.contact.label"/></label>
                                    <div class="controls">
                                        <g:textField name="contact.name"
                                                     value="${contact?.name}"
                                                     autocomplete="off"
                                                     class="span12"/>
                                        <g:hiddenField name="contact.id"
                                                       value="${contact?.id}"/>
                                    </div>
                                </div>

                                <div class="control-group">
                                    <label class="control-label">
                                        <g:message code="crmProject.status.label"/>
                                    </label>

                                    <div class="controls">
                                        <g:select name="status.id" from="${metadata.statusList}"
                                                  optionKey="id"
                                                  value="${crmProject.statusId}" class="span12"/>
                                    </div>
                                </div>

                                <div class="control-group">
                                    <label class="control-label">
                                        <g:message code="crmProject.type.label"/>
                                    </label>

                                    <div class="controls">
                                        <g:select name="type.id" from="${metadata.typeList}"
                                                  optionKey="id" noSelection="['': '']"
                                                  value="${crmProject.typeId}" class="span12"/>
                                    </div>
                                </div>

                                <div class="control-group">
                                    <label class="control-label">
                                        <g:message code="crmProject.category.label"/>
                                    </label>

                                    <div class="controls">
                                        <g:select name="category.id" from="${metadata.categoryList}"
                                                  optionKey="id" noSelection="['': '']"
                                                  value="${crmProject.categoryId}" class="span12"/>
                                    </div>
                                </div>

                                <div class="control-group">
                                    <label class="control-label">
                                        <g:message code="crmProject.username.label"/>
                                    </label>

                                    <div class="controls">
                                        <g:select name="username" from="${metadata.userList}" optionKey="username"
                                                  optionValue="name"
                                                  noSelection="${['': '']}"
                                                  value="${crmProject.username}" class="span12"/>
                                    </div>
                                </div>

                            </div>
                        </div>

                        <div class="span3">
                            <div class="row-fluid">
                                <div class="control-group">
                                    <label class="control-label">
                                        <g:message code="crmProject.date1.label"/>
                                    </label>

                                    <div class="controls">
                                        <div class="inline input-append date"
                                             data-date="${formatDate(type: 'date', date: crmProject.date1 ?: new Date())}">
                                            <g:textField name="date1" class="span11" size="10"
                                                         value="${formatDate(type: 'date', date: crmProject.date1)}"/><span
                                                class="add-on"><i
                                                    class="icon-th"></i></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="control-group">
                                    <label class="control-label">
                                        <g:message code="crmProject.date2.label"/>
                                    </label>

                                    <div class="controls">
                                        <div class="inline input-append date"
                                             data-date="${formatDate(type: 'date', date: crmProject.date2 ?: new Date())}">
                                            <g:textField name="date2" class="span11" size="10"
                                                         value="${formatDate(type: 'date', date: crmProject.date2)}"/><span
                                                class="add-on"><i
                                                    class="icon-th"></i></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="control-group">
                                    <label class="control-label">
                                        <g:message code="crmProject.date3.label"/>
                                    </label>

                                    <div class="controls">
                                        <div class="inline input-append date"
                                             data-date="${formatDate(type: 'date', date: crmProject.date3 ?: new Date())}">
                                            <g:textField name="date3" class="span11" size="10"
                                                         value="${formatDate(type: 'date', date: crmProject.date3)}"/><span
                                                class="add-on"><i
                                                    class="icon-th"></i></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="control-group">
                                    <label class="control-label">
                                        <g:message code="crmProject.date4.label"/>
                                    </label>

                                    <div class="controls">
                                        <div class="inline input-append date"
                                             data-date="${formatDate(type: 'date', date: crmProject.date4 ?: new Date())}">
                                            <g:textField name="date4" class="span11" size="10"
                                                         value="${formatDate(type: 'date', date: crmProject.date4)}"/><span
                                                class="add-on"><i
                                                    class="icon-th"></i></span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="span3">
                            <div class="row-fluid">
                                <f:field property="budget" label="crmProject.budget.label">
                                    <g:textField name="budget"
                                                 value="${fieldValue(bean: crmProject, field: 'budget')}"
                                                 class="span8"/>
                                </f:field>

                                <f:field property="actual" label="crmProject.actual.label">
                                    <g:textField name="actual"
                                                 value="${fieldValue(bean: crmProject, field: 'actual')}"
                                                 class="span8"/>
                                </f:field>
                                <f:field property="currency" label="crmProject.currency.label">
                                    <g:select from="${metadata.currencyList}" name="currency"
                                              value="${crmProject.currency}" class="span8"/>
                                </f:field>
                            </div>
                        </div>

                    </div>
                </div>

                <div class="tab-pane" id="items">
                    <table class="table table-striped">
                        <thead>
                        <tr>
                            <th><g:message code="crmProjectItem.orderIndex.label" default="#"/></th>
                            <th><g:message code="crmProjectItem.name.label" default="Name"/></th>
                            <th><g:message code="crmProjectItem.budget.label" default="Comment"/></th>
                            <th><g:message code="crmProjectItem.actual.label" default="Budget"/></th>
                            <th><g:message code="crmProjectItem.vat.label" default="Actual"/></th>
                        </tr>
                        </thead>
                        <tbody>

                        <g:each in="${items}" var="item" status="i">
                            <tr>
                                <td style="width: 5%;">
                                    <input type="hidden" name="items[${i}].id" value="${item.id}"/>

                                    <g:textField name="items[${i}].orderIndex" value="${item.orderIndex}"
                                        style="width: 99%"/>
                                </td>
                                <td style="width: 45%">
                                    <g:textField name="items[${i}].name" value="${item.name}"
                                        style="width: 99%"/>
                                </td>
                                <td>
                                    <g:textField name="items[${i}].budget" value="${fieldValue(bean: item, field: 'budget')}"
                                        style="width: 99%"/>
                                </td>
                                <td>
                                    <g:textField name="items[${i}].actual" value="${fieldValue(bean: item, field: 'actual')}"
                                        style="width: 99%"/>
                                </td>
                                <td style="width: 10%;">
                                    <g:select name="items[${i}].vat" from="${metadata.vatList}" value="${formatNumber(number:item.vat, minFractionDigits: 2)}"
                                              optionKey="${{formatNumber(number:it.value, minFractionDigits: 2)}}" optionValue="label" style="width:99%;"/>
                                </td>
                            </tr>
                        </g:each>

                        <g:each in="${(items.size())..(items.size()+2)}" var="i">
                            <tr>
                                <td style="width: 5%">
                                    <g:textField name="items[${i}].orderIndex" value="${items[i]?.orderIndex}"
                                        style="width: 99%"/>
                                </td>
                                <td style="width: 45%;">
                                    <g:textField name="items[${i}].name" value="${items[i]?.name}"
                                        style="width: 99%"/>
                                </td>
                                <td>
                                    <g:textField name="items[${i}].budget" value="${formatNumber(number: items[i]?.budget)}"
                                        style="width: 99%"/>
                                </td>
                                <td>
                                    <g:textField name="items[${i}].actual" value="${formatNumber(number: items[i]?.actual)}"
                                        style="width: 99%"/>
                                </td>
                                <td style="width: 10%;">
                                    <g:select name="items[${i}].vat" from="${metadata.vatList}" value="${formatNumber(number:items[i]?.vat, minFractionDigits: 2)}"
                                              optionKey="${{formatNumber(number:it.value, minFractionDigits: 2)}}" optionValue="label" style="width:99%;"/>
                                </td>
                            </tr>
                        </g:each>
                        </tbody>
                    </table>
                </div>

                <div class="tab-pane" id="desc">
                    <f:field property="description">
                        <g:textArea name="description" rows="10" cols="80"
                                    value="${crmProject.description}" class="span11"/>
                    </f:field>
                </div>
            </div>
        </div>

        <div class="form-actions">
            <crm:button visual="success" icon="icon-ok icon-white" label="crmProject.button.save.label"/>
        </div>

    </f:with>

</g:form>

</body>
</html>
