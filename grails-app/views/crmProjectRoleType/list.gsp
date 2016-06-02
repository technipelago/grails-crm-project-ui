<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmProjectRoleType.label', default: 'Project Role')}"/>
    <title><g:message code="crmProjectRoleType.list.title" args="[entityName]"/></title>
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

<crm:header title="crmProjectRoleType.list.title" args="[entityName]"/>

<div class="row-fluid">
    <div class="span9">

        <table class="table table-striped">
            <thead>
            <tr>

                <g:sortableColumn property="name"
                                  title="${message(code: 'crmProjectRoleType.name.label', default: 'Name')}"/>

                <g:sortableColumn property="description"
                                  title="${message(code: 'crmProjectRoleType.description.label', default: 'Description')}"/>
                <th></th>
            </tr>
            </thead>
            <tbody>
            <g:each in="${crmProjectRoleTypeList}" var="crmProjectRoleType">
                <tr>

                    <td>
                        <g:link action="edit" id="${crmProjectRoleType.id}">
                            ${fieldValue(bean: crmProjectRoleType, field: "name")}
                        </g:link>
                    </td>

                    <td>

                        <g:decorate max="100" include="abbreviate" encode="HTML">${crmProjectRoleType.description}</g:decorate>

                    </td>
                    <td style="text-align:right;width:50px;">
                        <g:link action="moveUp" id="${crmProjectRoleType.id}"><i
                                class="icon icon-arrow-up hide"></i></g:link>
                        <g:link action="moveDown" id="${crmProjectRoleType.id}"><i
                                class="icon icon-arrow-down hide"></i></g:link>
                    </td>
                </tr>
            </g:each>
            </tbody>
        </table>

        <crm:paginate total="${crmProjectRoleTypeTotal}"/>

        <div class="form-actions">
            <crm:button type="link" action="create" visual="success" icon="icon-file icon-white"
                        label="crmProjectRoleType.button.create.label"
                        permission="crmProjectRoleType:create"/>
        </div>

    </div>

    <div class="span3">
        <crm:submenu/>
    </div>
</div>

</body>
</html>
