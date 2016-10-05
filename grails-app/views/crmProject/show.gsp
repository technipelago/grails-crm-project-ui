<%@ page import="grails.plugins.crm.core.DateUtils; grails.plugins.crm.project.CrmProject" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmProject.label', default: 'Project')}"/>
    <title><g:message code="crmProject.show.title" args="[entityName, crmProject]"/></title>
    <r:require module="select2"/>
    <r:script>
        $(document).ready(function () {
            $("a.crm-change-status").click(function(ev) {
                ev.preventDefault();
                var status = $(this).data('crm-status');
                $.post("${createLink(action: 'changeStatus', id: crmProject.id)}", {status: status}, function(data) {
                    window.location.reload();
                });
            });

            $("#role-list a.crm-delete").click(function(ev) {
                ev.preventDefault();

                if(confirm("${message(code: 'crmProjectRole.delete.confirm', default: 'Remove role?')}")) {
                    var id = $(this).data("crm-id");
                    $.post("${createLink(action: 'deleteRole', id: crmProject.id)}", {r: id}, function(data) {
                        window.location.href = "${createLink(action: 'show', id: crmProject.id, fragment: 'roles')}";
                    });
                }
            });
            $("#role-list a.crm-edit").click(function(ev) {
                ev.preventDefault();
                var $modal = $("#roleModal");
                var id = $(this).data('crm-id');
                $modal.load("${createLink(action: 'editRole', id: crmProject.id)}?r=" + id, function() {
                    $modal.modal('show');
                });
            });
            $("#add-role").click(function(ev) {
                ev.preventDefault();
                var $modal = $("#roleModal");
                $modal.load("${createLink(action: 'addRole', id: crmProject.id)}", function() {

                    var $searchField = $('input[name="related"]', $modal);

                    $searchField.select2({
                        ajax: {
                            url: "${createLink(controller: 'crmContact', action: 'autocompleteContact')}",
                            dataType: 'json',
                            data: function (term, page) {
                                return {
                                    q: term, // search term
                                    limit: 10
                                };
                            },
                            results: function (data, page) {
                                return {results: data};
                            }
                        },
                        placeholder: "${message(code: 'crmProjectRole.create.placeholder')}",
                        allowClear: true,
                        minimumInputLength: 1,
                        createSearchChoice: function(term) {
                            var sanitized = term.replace(/,/g, " ")
                            return {id: sanitized, name: sanitized};
                        },
                        createSearchChoicePosition: "top",
                        escapeMarkup: function (m) { return m; },
                        formatResult: function(data) { return data.recent ? '<strong>' + data.name + '</strong>' : data.name; },
                        formatSelection: function(data) { return data.name; },
                        formatNoMatches: function (term) { return "${message(code: 'crmContact.search.noresult')}"; },
                        formatInputTooShort: function (input, min) { return "${message(code: 'crmContact.search.help')}"; },
                        formatInputTooLong: function (input, max) { return "${message(code: 'crmContact.search.help')}"; },
                        formatLoadMore: function (pageNumber) { return "${message(code: 'crmContact.search.loading')}"; },
                        formatSearching: function () { return "${message(code: 'crmContact.search.searching')}"; }
                    });

                    $modal.modal('show');
                });
            });
        });
    </r:script>
</head>

<body>

<div class="row-fluid">
    <div class="span9">

        <header class="page-header clearfix">
            <img src="${resource(dir: 'images', file: 'project-icon.png')}" class="avatar pull-right"
                 width="64" height="64"/>

            <h1>
                ${crmProject}
                <crm:favoriteIcon bean="${crmProject}"/>
                <small>${reference ?: customer}</small>
            </h1>
        </header>

        <div class="tabbable">
            <ul class="nav nav-tabs">
                <li class="active"><a href="#main" data-toggle="tab"><g:message code="crmProject.tab.main.label"/></a>
                </li>
                <li>
                    <a href="#budget" data-toggle="tab">
                        <g:message code="crmProject.tab.budget.label"/>
                        <crm:countIndicator count="${items.size()}"/>
                    </a>
                </li>
                <li>
                    <a href="#roles" data-toggle="tab">
                        <g:message code="crmProject.tab.roles.label"/>
                        <crm:countIndicator count="${roles.size()}"/>
                    </a>
                </li>
                <g:if test="${children}">
                    <li>
                        <a href="#children" data-toggle="tab">
                            <g:message code="crmProject.tab.children.label"/>
                            <crm:countIndicator count="${children.size()}"/>
                        </a>
                    </li>
                </g:if>
                <crm:pluginViews location="tabs" var="view">
                    <crm:pluginTab id="${view.id}" label="${view.label}" count="${view.model?.totalCount}"/>
                </crm:pluginViews>
            </ul>

            <div class="tab-content">
                <div class="tab-pane active" id="main">
                    <div class="row-fluid">
                        <div class="span4">
                            <dl>

                                <g:if test="${crmProject.name}">
                                    <dt><g:message code="crmProject.name.label" default="Name"/></dt>

                                    <dd><g:fieldValue bean="${crmProject}" field="name"/></dd>

                                </g:if>

                                <g:if test="${crmProject.number}">
                                    <dt><g:message code="crmProject.number.label" default="Number"/></dt>

                                    <dd><g:fieldValue bean="${crmProject}" field="number"/></dd>

                                </g:if>

                                <g:if test="${crmProject.parent}">
                                    <dt><g:message code="crmProject.parent.label" default="Main project"/></dt>

                                    <dd><g:link action="show"
                                                id="${crmProject.parentId}"><g:fieldValue bean="${crmProject}"
                                                                                             field="parent"/></g:link></dd>
                                </g:if>
                            </dl>
                        </div>

                        <div class="span4">
                            <dl>

                                <g:if test="${customer}">
                                    <dt><g:message code="crmProject.customer.label" default="Customer"/></dt>

                                    <dd>
                                        <g:link mapping="crm-contact-show" id="${customer?.id}">
                                            <g:fieldValue bean="${customer}" field="name"/>
                                        </g:link>
                                        <div class="muted">
                                            <g:fieldValue bean="${customer}" field="address"/>
                                        </div>
                                    </dd>

                                </g:if>

                                <g:if test="${contact}">
                                    <dt><g:message code="crmProject.contact.label" default="Contact"/></dt>

                                    <dd>
                                        <g:link mapping="crm-contact-show" id="${contact.id}">
                                            <g:fieldValue bean="${contact}" field="name"/>
                                        </g:link>
                                        <div class="muted">
                                            <g:fieldValue bean="${contact}" field="telephone"/>
                                        </div>
                                    </dd>

                                </g:if>

                                <g:if test="${crmProject.username}">
                                    <dt><g:message code="crmProject.username.label" default="Responsible"/></dt>
                                    <dd><crm:user username="${crmProject.username}">${name}</crm:user></dd>

                                </g:if>

                                <g:if test="${reference}">
                                    <dt><g:message code="crmProject.ref.label" default="Reference"/></dt>
                                    <dd><crm:referenceLink reference="${reference}"/></dd>

                                </g:if>

                                <g:if test="${crmProject.budget}">
                                    <dt><g:message code="crmProject.budget.label" default="Budget"/></dt>

                                    <dd>
                                        <g:formatNumber number="${crmProject.budget}"
                                                        type="currency"
                                                        currencyCode="${crmProject.currency ?: 'EUR'}"
                                                        maxFractionDigits="0"/>
                                    </dd>

                                    <dt><g:message code="crmProject.actual.label" default="Actual"/></dt>

                                    <dd>
                                        <g:formatNumber number="${crmProject.actual}"
                                                        type="currency"
                                                        currencyCode="${crmProject.currency ?: 'EUR'}"
                                                        maxFractionDigits="0"/>

                                        <span class="${crmProject.diff < 0 ? 'negative' : 'positive'}">
                                        (<g:formatNumber number="${crmProject.diff}"
                                                        type="currency" maxFractionDigits="0"
                                                        currencyCode="${crmProject.currency ?: 'EUR'}"/>
                                        = <g:formatNumber type="percent" number="${crmProject.actual / crmProject.budget}"/>)</span>
                                    </dd>
                                </g:if>
                            </dl>

                        </div>

                        <div class="span4">

                            <dl>

                                <g:if test="${crmProject.status}">
                                    <dt><g:message code="crmProject.status.label" default="Status"/></dt>

                                    <dd><g:fieldValue bean="${crmProject}" field="status"/></dd>

                                </g:if>

                                <g:if test="${crmProject.date1}">
                                    <dt><g:message code="crmProject.date1.label" default="Date 1"/></dt>

                                    <dd><g:formatDate date="${crmProject.date1}" type="date"/></dd>

                                </g:if>

                                <g:if test="${crmProject.date2}">
                                    <dt><g:message code="crmProject.date2.label" default="Date 2"/></dt>

                                    <dd>
                                        <g:formatDate date="${crmProject.date2}" type="date"/>
                                    </dd>

                                </g:if>

                                <g:if test="${crmProject.date3}">
                                    <dt><g:message code="crmProject.date3.label" default="Date 2"/></dt>

                                    <dd><g:formatDate date="${crmProject.date3}" type="date"/></dd>

                                </g:if>

                                <g:if test="${crmProject.date4}">
                                    <dt><g:message code="crmProject.date4.label" default="Date 4"/></dt>

                                    <dd><g:formatDate date="${crmProject.date4}" type="date"/></dd>

                                </g:if>
                            </dl>
                        </div>

                    </div>


                    <g:if test="${crmProject.description}">
                        <div class="row-fluid">
                            <div class="span9">
                                <p style="background-color: #fefefe; border: 1px solid #f0f0f0; border-radius: 3px;">
                                    <g:decorate>${crmProject.description}</g:decorate>
                                </p>
                            </div>
                        </div>
                    </g:if>

                    <g:form>
                        <g:hiddenField name="id" value="${crmProject.id}"/>
                        <div class="form-actions btn-toolbar">

                            <crm:selectionMenu location="crmProject" visual="primary">
                                <crm:button type="link" controller="crmProject" action="index"
                                            visual="primary" icon="icon-search icon-white"
                                            label="crmProject.find.label" permission="crmProject:show"/>
                            </crm:selectionMenu>

                            <crm:button type="link" group="true" action="edit" id="${crmProject.id}" visual="warning"
                                        icon="icon-pencil icon-white"
                                        label="crmProject.button.edit.label" permission="crmProject:edit">
                                <button class="btn btn-warning dropdown-toggle" data-toggle="dropdown">
                                    <span class="caret"></span>
                                </button>
                                <ul class="dropdown-menu">
                                    <g:each in="${metadata.statusList}" var="status">
                                        <li class="${crmProject.status == status ? 'disabled' : ''}">
                                            <a href="#" data-crm-status="${status.param}" class="crm-change-status">
                                                ${message(code: 'crmProject.update.status.message', default: 'Change status to {1}', args: [crmProject, status])}
                                            </a>
                                        </li>
                                    </g:each>
                                </ul>
                            </crm:button>

                            <crm:button type="link" group="true" action="create"
                                        visual="success" icon="icon-file icon-white"
                                        label="crmProject.button.create.label"
                                        title="crmProject.button.create.help"
                                        permission="crmProject:create">
                            </crm:button>

                            <div class="btn-group">
                                <button class="btn btn-info dropdown-toggle" data-toggle="dropdown">
                                    <i class="icon-info-sign icon-white"></i>
                                    <g:message code="crmProject.button.view.label" default="View"/>
                                    <span class="caret"></span>
                                </button>
                                <ul class="dropdown-menu">
                                    <g:if test="${selection}">
                                        <li>
                                            <select:link action="list" selection="${selection}"
                                                         params="${[view: 'list']}">
                                                <g:message code="crmProject.show.result.label"
                                                           default="Show result in list view"/>
                                            </select:link>
                                        </li>
                                    </g:if>
                                    <crm:hasPermission permission="crmProject:createFavorite">
                                        <crm:user>
                                            <g:if test="${crmProject.isUserTagged('favorite', username)}">
                                                <li>
                                                    <g:link action="deleteFavorite" id="${crmProject.id}"
                                                            title="${message(code: 'crmProject.button.favorite.delete.help', args: [crmProject])}">
                                                        <g:message
                                                                code="crmProject.button.favorite.delete.label"/></g:link>
                                                </li>
                                            </g:if>
                                            <g:else>
                                                <li>
                                                    <g:link action="createFavorite" id="${crmProject.id}"
                                                            title="${message(code: 'crmProject.button.favorite.create.help', args: [crmProject])}">
                                                        <g:message
                                                                code="crmProject.button.favorite.create.label"/></g:link>
                                                </li>
                                            </g:else>
                                        </crm:user>
                                    </crm:hasPermission>
                                </ul>
                            </div>
                        </div>

                        <crm:timestamp bean="${crmProject}"/>

                    </g:form>

                </div>

                <div class="tab-pane" id="budget">
                    <tmpl:items bean="${crmProject}" list="${items}"/>
                </div>

                <div class="tab-pane" id="roles">
                    <tmpl:roles bean="${crmProject}" list="${roles}"/>

                    <g:form>
                        <g:hiddenField name="id" value="${crmContact?.id}"/>
                        <div class="form-actions btn-toolbar">
                            <crm:hasPermission permission="crmProject:edit">
                                <g:link action="addRole" id="${crmProject.id}" class="btn btn-success"
                                        elementId="add-role">
                                    <i class="icon-resize-small icon-white"></i>
                                    <g:message code="crmProjectRole.button.create.label" default="Add Role"/>
                                </g:link>
                            </crm:hasPermission>
                        </div>
                    </g:form>
                </div>

                <g:if test="${children}">
                    <div class="tab-pane" id="children">
                        <tmpl:children bean="${crmProject}" list="${children}"/>
                    </div>
                </g:if>

                <crm:pluginViews location="tabs" var="view">
                    <div class="tab-pane tab-${view.id}" id="${view.id}">
                        <g:render template="${view.template}" model="${view.model}" plugin="${view.plugin}"/>
                    </div>
                </crm:pluginViews>

            </div>
        </div>

    </div>

    <div class="span3">

        <div id="summary" class="alert alert-info">
            <g:render template="summary" model="${[bean: crmProject]}"/>
        </div>

        <g:render template="/tags" plugin="crm-tags" model="${[bean: crmProject]}"/>

    </div>
</div>

<div class="modal hide fade" id="roleModal"></div>

</body>
</html>
