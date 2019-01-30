<%
    ui.includeJavascript("uicommons", "handlebars/handlebars.min.js")
    ui.includeCss("intelehealth", "overview/patientSummary.css")
    ui.includeCss("intelehealth", "overview/back-to-top.css")
    ui.includeCss("intelehealth", "overview/ui-carousel.css")
    ui.includeCss("intelehealth", "overview/common-styles.css")
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeJavascript("intelehealth", "angularJS/angular.min.js")
    ui.includeJavascript("intelehealth", "angularJS/angular-resource.min.js")
    ui.includeJavascript("intelehealth", "jquery/jquery.js")
    ui.includeJavascript("intelehealth", "angularJS/angular-sanitize.js")
    ui.includeJavascript("intelehealth", "angularJS/angular-animate.js")
    ui.includeJavascript("intelehealth", "angular-ui-bootstrap/dist/ui-bootstrap-tpls.js")
    ui.includeJavascript("intelehealth", "angular-ui-carousel/dist/ui-carousel.js")
    ui.includeJavascript("intelehealth", "constants.js")
    ui.includeJavascript("intelehealth", "recent_visits/recent_visits.module.js")
    ui.includeJavascript("intelehealth", "recent_visits/recent_visits.service.js")
    ui.includeJavascript("intelehealth", "recent_visits/recent_visits.controller.js")
    ui.includeJavascript("intelehealth", "intelehealth_patient_profile_image/intelehealth_patient_profile_image.module.js")
    ui.includeJavascript("intelehealth", "intelehealth_patient_profile_image/intelehealth_patient_profile_image.service.js")
    ui.includeJavascript("intelehealth", "intelehealth_patient_profile_image/intelehealth_patient_profile_image.controller.js")
    ui.includeJavascript("intelehealth", "intelehealth_additional_docs_images/intelehealth_additional_docs_images.module.js")
    ui.includeJavascript("intelehealth", "intelehealth_additional_docs_images/intelehealth_additional_docs_images.service.js")
    ui.includeJavascript("intelehealth", "intelehealth_additional_docs_images/intelehealth_additional_docs_images.controller.js")
    ui.includeJavascript("intelehealth", "intelehealth_physical_exam_images/intelehealth_physical_exam_images.module.js")
    ui.includeJavascript("intelehealth", "intelehealth_physical_exam_images/intelehealth_physical_exam_images.service.js")
    ui.includeJavascript("intelehealth", "intelehealth_physical_exam_images/intelehealth_physical_exam_images.controller.js")
    ui.includeJavascript("intelehealth", "EncounterService/encounter.module.js")
    ui.includeJavascript("intelehealth", "EncounterService/encounter.service.js")
%>

${ ui.includeFragment("coreapps", "patientHeader", [ patient: patient]) }

<div class="info-body jump-header">
    <span class="jump-label">Jump to: </span>
        <i class="icon-vitals"><a href="#vitals">Vitals</a></i>
        <i class="icon-group"><a href="#famhist">Family History</a></i>
        <i class="icon-book"><a href="#history">Past Medical History</a></i>
        <i class="icon-comment"><a href="#complaints">Presenting Complaints</a></i>
        <i class="icon-stethoscope"><a href="#exam">On Examination</a></i>
        <i class="icon-diagnosis"><a href="#diagnosis">Diagnoses</a></i>
      <br>
      <div id = "jumper">
        <i class="icon-book"><a href="#interpretation">Interpretation</a></i>
        <i class="icon-comments"><a href="#comments">Doctor's Note</a></i>
        <i class="icon-medicine"><a href="#meds">Prescribed Medication</a></i>
        <i class="icon-beaker"><a href="#orderedTests">Prescribed Tests</a></i>
        <i class="icon-comments"><a href="#advice">Medical Advice</a></i>
        <i class="icon-book"><a href="#followup">Follow Up</a></i>
        </div>
</div>

<div style="border: 2px solid green";><small style="color:red;"><span class="icon-warning-sign"></span><i> <b>Note:</b> 
  This history note and physical exam note was generated by a community health worker with the support
  of the Intelehealth mobile application. It collects only preliminary findings and may not gather all of the patient's
  clinical information, especially sensitive information or complex physical exam information which is hard for the
  health worker to collect. Please verify crucial clinical information and collect any additional information you
  require by speaking with the patient directly. </i></small></div>

<br>
  <br>
    <div class="clear"></div>
        <div class="dashboard clear" ng-app="patientSummary" ng-controller="PatientSummaryController">
            <div class="long-info-container column">
                    ${ui.includeFragment("intelehealth", "overview/vitals", [patient: patient])}
                    ${ui.includeFragment("intelehealth", "overview/famhist", [patient: patient])}
                    ${ui.includeFragment("intelehealth", "overview/history", [patient: patient])}
                    ${ui.includeFragment("intelehealth", "overview/complaint", [patient: patient])}
                    ${ui.includeFragment("intelehealth", "overview/exam", [patient: patient])}
                    ${ui.includeFragment("intelehealth", "overview/additionalDocsImages", [patient: patient])}
                    ${ui.includeFragment("intelehealth", "overview/interpretation", [patient: patient])}
                    ${ui.includeFragment("intelehealth", "overview/patientInteraction", [patient: patient])}
                    ${ui.includeFragment("intelehealth", "overview/encounterDiagnoses", [patient: patient, formFieldName: 'Consultation'])}
                    ${ui.includeFragment("intelehealth", "overview/additionalComments", [patient: patient])}
                    ${ui.includeFragment("intelehealth", "overview/meds", [patient: patient])}
                    ${ui.includeFragment("intelehealth", "overview/orderedTests", [patient: patient])}
                    ${ui.includeFragment("intelehealth", "overview/advice", [patient: patient])}
                    ${ui.includeFragment("intelehealth", "overview/followUp", [patient: patient])}
                    ${ui.includeFragment("intelehealth", "overview/submit", [patient: patient])}
       </div>
        </div>
        <a id="back2Top" title="Back to top" href="#">&#10148;</a>


<script>
var visitNoteEncounterUuid = "";
var path = window.location.search;
var i = path.indexOf("visitId=");
var visitId = path.substr(i + 8, path.length);
var isVisitNotePresent = false;
var app = angular.module('patientSummary', ['ngAnimate', 'ngResource', 'EncounterModule', 'ngSanitize',
  'recentVisit', 'interpretation', 'vitalsSummary', 'famhistSummary', 'historySummary', 'complaintSummary', 'examSummary', 'diagnoses',
  'medsSummary', 'orderedTestsSummary', 'adviceSummary', 'intelehealthPatientProfileImage',
  'intelehealthAdditionalDocs', 'ui.bootstrap', 'additionalComments', 'FollowUp', 'ui.carousel', 'Submit', 'Interaction']);

app.controller('PatientSummaryController', function(\$scope, \$http, recentVisitFactory, EncounterFactory, \$timeout) {
  var patient = "${ patient.uuid }";
  var date2 = new Date();
  \$scope.isLoading = true;
  \$scope.visitEncounters = [];
  \$scope.visitObs = [];
  \$scope.visitNoteData = [];
  \$scope.visitStatus = false;
  recentVisitFactory.fetchVisitDetails(visitId).then(function(data) {
  						\$scope.visitDetails = data.data;
  						\$scope.visitEncounters = data.data.encounters;
  						if(\$scope.visitEncounters.length !== 0) {
  							angular.forEach(\$scope.visitEncounters, function(value, key){
  								var encounter = value.display;
                  console.log(encounter);
  								if(encounter.match("Visit Note") !== null) {
                    // To get encounter value for fragments if encounter already exists!
                    EncounterFactory.encounterValue = value.uuid;
  									isVisitNotePresent = true;
  								}
                  if(encounter.match("RHPT-Interpretation") !== null) {
                    // To get encounter value for fragments if encounter already exists!
                    EncounterFactory.rhpt_encounter = value.uuid;
  									isVisitNotePresent = true;
  								}
  							});
  						}
  						if (isVisitNotePresent == false || \$scope.visitEncounters.length == 0) {
                var promiseuuid = EncounterFactory.postEncounter().then(function(response){
                  return response;
                });
                promiseuuid.then(function(x){
                      \$scope.uuid = x;
                      \$scope.uuid3;
                      var url2 = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/provider?user=" + \$scope.uuid;
                      \$http.get(url2).then(function(response){
                        angular.forEach(response.data.results, function(v, k){
    											var uuid = v.uuid;
                          var rhpt_encounter = 'aa5f275f-ab3d-4efe-9bbb-7103b7a2c96d';
                          var url1 = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/encounter";
                          var json = {
                                      patient: patient,
                                      encounterType: window.constantConfigObj.encounterTypeVisitNote,
                                      encounterProviders:[{
                                        provider: uuid,
                                        encounterRole: window.constantConfigObj.encounterRoleDoctor
                                      }],
                                      visit: visitId,
                                      encounterDatetime: date2
                                    };
                          \$http.post(url1, JSON.stringify(json)).then(function(response){
                              	\$scope.statuscode = "Success";
                                // Set encounter value after creating new encounter
                                EncounterFactory.encounterValue = response.data.uuid;
                          }, function(response){
                            \$scope.statuscode = "Failed to create Encounter";
                          });
                          //RHPT interpretation encounter
                          var rhpt_json = {
                                      patient: patient,
                                      encounterType: rhpt_encounter,
                                      encounterProviders:[{
                                        provider: uuid,
                                        encounterRole: window.constantConfigObj.encounterRoleDoctor
                                      }],
                                      visit: visitId,
                                      encounterDatetime: date2
                                    };
                          \$http.post(url1, JSON.stringify(rhpt_json)).then(function(response){
                              	\$scope.statuscode = "Success";
                                // Set encounter value after creating new encounter
                                EncounterFactory.rhpt_encounter = response.data.uuid;
                          }, function(response){
                            \$scope.statuscode = "Failed to create Encounter";
                          });
    										});
                      },function(response){
                        console.log("Get user uuid Failed!");
                      });
                });
  						}
  					}, function(error) {
  						console.log(error);
  					});
});
</script>

<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/referenceapplication/home.page' },
        { label: "${ ui.format(patient.familyName) }, ${ ui.format(patient.givenName) }" ,
            link: '${ui.pageLink("intelehealth", "overview/patientSummary", [patientId: patient.id])}'}
    ]
    jq(function(){
        jq(".tabs").tabs();
        // make sure we reload the page if the location is changes; this custom event is emitted by by the location selector in the header
        jq(document).on('sessionLocationChanged', function() {
            window.location.reload();
        });
    });
    var patient = { id: ${ patient.id } };
    \$(window).scroll(function() {
        var scroller = \$(window).scrollTop();
        if (scroller > 100) {
            \$('#back2Top').fadeIn();
        } else {
            \$('#back2Top').fadeOut();
        }
    });
    \$(document).ready(function() {
        \$("#back2Top").click(function(event) {
            event.preventDefault();
            \$("html, body").animate({ scrollTop: 0 }, "slow");
            return false;
        });
    });
</script>

</script>