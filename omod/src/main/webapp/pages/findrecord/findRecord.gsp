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
Search <input type='text' ng-model='searchText'>
<table>
    <th>Patient ID</th>
    <th>Name</th>
    <th>Gender</th>
    <th>Age</th>
    <th>Location</th>
    <th>Nurse</th>
    <th>Doctor</th>
<tr ng-repeat="vis in values | filter:searchText | startFrom:currentPage*pageSize | limitTo:pageSize">
    <td>{{vis.patient.identifiers[0].identifier}}</td>
    <td><a href='/openmrs/intelehealth/intelehealthPatientDashboard.page?patientId={{vis.patient.uuid}}'>{{vis.patient.person.display}}</a></td>
    <td>{{vis.patient.person.gender}}</td>
    <td>{{vis.patient.person.age}}</td>
    <td>{{vis.location.display}}</td>
    <td>{{vis.nurse}}<br>
    <small>{{vis.nurseTime | date: 'dd.MM.yyyy, HH:mm:ss'}}</small></td>
    <td>{{vis.doctor}}<br>
    <small>{{vis.doctorTime | date: 'dd.MM.yyyy, HH:mm:ss'}}</small></td>
</tr>
</table>
<div style="text-align:right; width:100%; padding:0;">
<button ng-disabled="currentPage == 0" ng-click="currentPage=currentPage - 1">Previous</button>
    {{currentPage+1}}/{{numberOfPages()}}
    <button ng-disabled="currentPage >= values.length/pageSize - 1" ng-click="currentPage=currentPage + 1">
    Next
    </button>
    </div>
</div>
</div>



<script>
var patient = angular.module('patient', []);
patient.controller('patientController', function(\$scope, \$http) {
    \$scope.currentPage = 0;
    \$scope.pageSize = 10;
    \$scope.values = [];
    \$scope.numberOfPages=function(){
        return Math.ceil(\$scope.values.length/\$scope.pageSize);                
    }
//\$scope.values = [];
\$scope.encounters =[];
let url = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/visit/?v=custom:(uuid)"
\$http.get(url).then(function(response){
    for(var i = 0; i<response.data.results.length; i++){
        let url1 = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/visit/" +response.data.results[i].uuid+ "?v=custom:(patient:(uuid,identifiers:(identifier),person:(display,gender,age)),location:(display),encounters:(uuid))"
        \$http.get(url1).then(function(response){
        var data = response.data
        \$scope.encounters = response.data.encounters
        var length = response.data.encounters.length
        for (var j = 0; j<length; j++){
            let url2 = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/encounter/" + \$scope.encounters[j].uuid
            \$http.get(url2).then(function(response){
                var encounter =  response.data.encounterType.display;
                if (encounter.match("ADULTINITIAL") !== null) {
                    data.nurseTime = response.data.encounterDatetime
                    var display = response.data.encounterProviders[0].display
                    var obs = display.split(':');
                    data.nurse = obs[0]
                }
                 if (encounter.match("Visit Complete") !== null) {
                    data.doctorTime = response.data.encounterDatetime
                    var display = response.data.encounterProviders[0].display
                    console.log(display);
                    var obs = display.split(':');
                    data.doctor = obs[0]
                }
            })
        }
        \$scope.values.push(data)   
})
}
})
})
patient.filter('startFrom', function() {
    return function(input, start) {
        start = +start; //parse to int
        return input.slice(start);
    }
});

</script>

