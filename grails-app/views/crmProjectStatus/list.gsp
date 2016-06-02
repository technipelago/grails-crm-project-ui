<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmProjectStatus.label', default: 'Project Status')}"/>
    <title><g:message code="crmProjectStatus.list.title" args="[entityName]"/></title>
    <r:script>
        $(document).ready(function() {
            $(".table-striped tr").hover(function() {
                $("i", $(this)).removeClass('hide');
            }, function() {
                $("i", $(this)).addClass('hide');
            });
        });
    </r:script>
</head>

<body>

<crm:header title="crmProjectStatus.list.title" args="[entityName]"/>

<div class="row-fluid">
    <div class="span9">

        <table class="table table-striped">
            <thead>
            <tr>

                <g:sortableColumn property="name"
                                  title="${message(code: 'crmProjectStatus.name.label', default: 'Name')}"/>

                <g:sortableColumn property="description"
                                  title="${message(code: 'crmProjectStatus.description.label', default: 'Description')}"/>
                <th></th>
            </tr>
            </thead>
            <tbody>
            <g:each in="${crmProjectStatusList}" var="crmProjectStatus">
                <tr>

                    <td>
                        <g:link action="edit" id="${crmProjectStatus.id}">
                            ${fieldValue(bean: crmProjectStatus, field: "name")}
                        </g:link>
                    </td>

                    <td>

                        <g:decorate max="100" include="abbreviate" encode="HTML">${crmProjectStatus.description}</g:decorate>

                    </td>
                    <td style="text-align:right;width:50px;">
                        <g:link action="moveUp" id="${crmProjectStatus.id}"><i
                                class="icon icon-arrow-up hide"></i></g:link>
                        <g:link action="moveDown" id="${crmProjectStatus.id}"><i
                                class="icon icon-arrow-down hide"></i></g:link>
                    </td>
                </tr>
            </g:each>
            </tbody>
        </table>

        <crm:paginate total="${crmProjectStatusTotal}"/>

        <div class="form-actions">
            <crm:button type="link" action="create" visual="success" icon="icon-file icon-white"
                        label="crmProjectStatus.button.create.label"
                        permission="crmProjectStatus:create"/>
        </div>

    </div>

    <div class="span3">
        <crm:submenu/>
    </div>
</div>

</body>
</html>
