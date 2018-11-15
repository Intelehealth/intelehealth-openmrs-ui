<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeCss("intelehealth", "findrecord/findRecord.css")
    ui.includeJavascript("intelehealth", "angularJS/angular.min.js")
    ui.includeJavascript("intelehealth", "angularJS/angular-resource.min.js")
    ui.includeJavascript("intelehealth", "jquery/jquery.js")
    ui.includeJavascript("intelehealth", "angularJS/angular-sanitize.js")
    ui.includeJavascript("intelehealth", "angularJS/angular-animate.js")
    ui.includeJavascript("intelehealth", "angular-ui-bootstrap/dist/ui-bootstrap-tpls.js")
    ui.includeJavascript("intelehealth", "angular-ui-carousel/dist/ui-carousel.js")
%>
<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/referenceapplication/home.page' },
        { label: "${ ui.message("intelehealth.findPatient.app.label")}"}
    ];
    jq(function() {
        var resultTemplate = _.template(jq('#result-template').html());
        // this is a quick hack -- we really want to autosearch after they type a few keys
        jq('#patient-search-form').submit(function() {
            var query = jq('#patient-search').val();
            var customRep = 'custom:(uuid,identifiers:(identifierType:(name),identifier),person)';
            jq.getJSON('/' + OPENMRS_CONTEXT_PATH + '/ws/rest/v1/patient', {v: customRep, q: query }, function(data) {
                var resultTarget = jq('#patient-search-results');
                resultTarget.html('');
                _.each(data.results, function(patient) {
                    resultTarget.append(resultTemplate({ patient: patient }));
                });
            });
            return false;
        });
        jq('#patient-search').focus();
        jq('#patient-search-results').on('click', '.patient-search-result', function(evt) {
            location.href = jq(this).find('a.button').attr('href');
        });
    });
</script>

<form method="get" id="patient-search-form">
    <input type="text" id="patient-search" placeholder="${ ui.message("intelehealth.findPatient.search.placeholder") }" autocomplete="off"/>
    <input type="submit" value="${ ui.message("intelehealth.findPatient.search.button") }"/>
</form>

<ul id="patient-search-results">
</ul>

<script type="text/template" id="result-template">
    <li class="patient-search-result" data-patient-uuid="{{- patient.uuid }}">
        {{ _.each(patient.identifiers, function(id) { }}
            <span class="patient-identifier">
                <span class="identifier-type">{{- id.identifierType.name }}</span>
                <span class="identifier">{{- id.identifier }}</span>
            </span>
        {{ }) }}
        <span class="preferred-name">
            {{- patient.person.preferredName.display }}
        </span>
        <span class="age">{{- patient.person.age }}</span>
        <span class="gender">{{- patient.person.gender }}</span>
        
		<a class="button" href="{{= '/' + OPENMRS_CONTEXT_PATH + '/intelehealth/intelehealthPatientDashboard.page?patientId=' + patient.uuid}}">${ ui.message("intelehealth.findPatient.result.view") }</a>
    </li>
</script>

<div ng-app="patient">
<div class="info-body" ng-controller="patientController">
<table>
<tr ng-repeat="vis in values">
<td>{{vis.data.patient.person.display}}</td>
<td>{{vis.data.patient.person.gender}}</td>
<td>{{vis.data.patient.person.age}}</td>
<td>{{vis.data.location.display}}</td>
<td>{{vis.data.encounters[0].encounterType.display}}</td>
</tr>
</table>
</div>
</div>

<script>
var patient = angular.module('patient', []);
patient.controller('patientController', function(\$scope, \$http) {
\$scope.values = [];
let url = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/visit/?v=custom:(uuid)"
\$http.get(url).then(function(response){
    for(var i = 0; i<response.data.results.length; i++){
        let url1 = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/visit/"+response.data.results[i].uuid+"?v=custom:(patient:(uuid,person:(display,gender,age)),location:(display),encounters:(encounterType))"
        \$http.get(url1).then(function(response){
        \$scope.values.push(response)
})
}
})
})

</script>