<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmProjectRoleType.label', default: 'Project Role')}"/>
    <title><g:message code="crmProjectRoleType.edit.title" args="[entityName, crmProjectRoleType]"/></title>
</head>

<body>

<crm:header title="crmProjectRoleType.edit.title" args="[entityName, crmProjectRoleType]"/>

<div class="row-fluid">
    <div class="span9">

        <g:hasErrors bean="${crmProjectRoleType}">
            <crm:alert class="alert-error">
                <ul>
                    <g:eachError bean="${crmProjectRoleType}" var="error">
                        <li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message
                                error="${error}"/></li>
                    </g:eachError>
                </ul>
            </crm:alert>
        </g:hasErrors>

        <g:form class="form-horizontal" action="edit" id="${crmProjectRoleType?.id}">
            <g:hiddenField name="version" value="${crmProjectRoleType?.version}"/>

            <div class="control-group">
                <label class="control-label">
                    <g:message code="crmProjectRoleType.name.label"/>
                </label>

                <div class="controls">
                    <g:textField name="name" value="${crmProjectRoleType.name}"  autofocus=""/>
                </div>
            </div>

            <div class="control-group">
                <label class="control-label">
                    <g:message code="crmProjectRoleType.description.label"/>
                </label>

                <div class="controls">
                    <g:textField name="description" value="${crmProjectRoleType.description}" />
                </div>
            </div>

            <div class="control-group">
                <label class="control-label">
                    <g:message code="crmProjectRoleType.param.label"/>
                </label>

                <div class="controls">
                    <g:textField name="param" value="${crmProjectRoleType.param}" />
                </div>
            </div>

            <div class="control-group">
                <label class="control-label">
                    <g:message code="crmProjectRoleType.icon.label"/>
                </label>

                <div class="controls">
                    <g:textField name="icon" value="${crmProjectRoleType.icon}" />
                </div>
            </div>

            <div class="control-group">
                <label class="control-label">
                    <g:message code="crmProjectRoleType.orderIndex.label"/>
                </label>

                <div class="controls">
                    <g:textField name="orderIndex" value="${crmProjectRoleType.orderIndex}" />
                </div>
            </div>

            <div class="control-group">
                <label class="control-label">
                    <g:message code="crmProjectRoleType.enabled.label"/>
                </label>

                <div class="controls">
                    <g:checkBox name="enabled" value="true" checked="${crmProjectRoleType.enabled}"/>
                </div>
            </div>

            <div class="form-actions">
                <crm:button visual="warning" icon="icon-ok icon-white"
                            label="crmProjectRoleType.button.update.label"/>
                <crm:button action="delete" visual="danger" icon="icon-trash icon-white"
                            label="crmProjectRoleType.button.delete.label"
                            confirm="crmProjectRoleType.button.delete.confirm.message"
                            permission="crmProjectRoleType:delete"/>
                <crm:button type="link" action="list"
                            icon="icon-remove"
                            label="crmProjectRoleType.button.cancel.label"/>
            </div>
        </g:form>
    </div>

    <div class="span3">
        <crm:submenu/>
    </div>
</div>
</body>
</html>
