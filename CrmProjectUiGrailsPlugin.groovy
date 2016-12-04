class CrmProjectUiGrailsPlugin {
    def groupId = ""
    def version = "2.4.1-SNAPSHOT"
    def grailsVersion = "2.2 > *"
    def dependsOn = [:]
    def loadAfter = ['crmProject']
    def pluginExcludes = [
            "grails-app/conf/ApplicationResources.groovy",
            "src/groovy/grails/plugins/crm/project/TestSecurityDelegate.groovy",
            "grails-app/views/error.gsp"
    ]
    def title = "GR8 CRM Project Management UI Plugin"
    def author = "Goran Ehrsson"
    def authorEmail = "goran@technipelago.se"
    def description = '''\
Project management user interface for GR8 CRM applications.
'''
    def documentation = "http://gr8crm.github.io/plugins/crm-project-ui/"
    def license = "APACHE"
    def organization = [name: "Technipelago AB", url: "http://www.technipelago.se/"]
    def issueManagement = [system: "github", url: "https://github.com/technipelago/grails-crm-project-ui/issues"]
    def scm = [url: "https://github.com/technipelago/grails-crm-project-ui"]

    def doWithApplicationContext = { applicationContext ->
        def crmPluginService = applicationContext.crmPluginService
        crmPluginService.registerView('crmMessage', 'index', 'tabs',
                [id: "crmProject", index: 280, label: "crmProject.label",
                        template: '/crmProject/messages', plugin: "crm-project-ui"]
        )
    }
}
