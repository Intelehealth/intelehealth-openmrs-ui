<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeCss("intelehealth", "findrecord/findRecord.css")
    ui.includeJavascript("intelehealth", "angularJS/angular.min.js")
%>
<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/referenceapplication/home.page' },
        { label: "${ ui.message("intelehealth.findPatient.app.label")}"}
    ];
</script>

<h3>${ ui.message("intelehealth.findPatient.allPatients") }</h3>

        
<div ng-app="patient">
<div class="info-body" ng-controller="patientController">
<div>Search <input type='text' ng-model='searchText'><div><br/>
<table>
    <th>SN</th>
    <th>Patient ID</th>
    <th>Name</th>
    <th>Gender</th>
    <th>Age</th>
    <th>Location</th>
    <th>Nurse</th>
    <th>Doctor</th>
<tr ng-repeat="vis in values | filter:searchText | startFrom:currentPage*pageSize | limitTo:pageSize">
    <td>{{((currentPage)*(pageSize))+\$index + 1}}</td>
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
<br/>
<div style="text-align:right; width:100%; padding:0;">
<button ng-disabled="currentPage == 0" ng-click="currentPage=numberOfPages()-(numberOfPages())">First</button>
   <button ng-disabled="currentPage == 0" ng-click="currentPage=currentPage-1"><</button>
    {{currentPage+1}}/{{numberOfPages()}}
    <button ng-disabled="(currentPage + 1) == numberOfPages()" ng-click="currentPage=currentPage+1">
        >
    </button>
    <button ng-disabled="(currentPage + 1) == numberOfPages()" ng-click="currentPage=numberOfPages()-1">Last</button>
</div>
</div>
</div>


<script>
var patient = angular.module('patient', []);
patient.controller('patientController', function(\$scope, \$http, \$filter) {
    \$scope.currentPage = 0;
    \$scope.pageSize = 10;
    \$scope.values = [];
    \$scope.numberOfPages=function(){
         var myFilteredData = \$filter('filter')(\$scope.values,\$scope.searchText); 
        return Math.ceil(myFilteredData.length/\$scope.pageSize);                
    }
let url = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/visit/?v=custom:(patient:(uuid,identifiers:(identifier),person:(display,gender,age)),location:(display),encounters:(uuid))"
\$http.get(url).then(function(response){
    angular.forEach(response.data.results, (v) => {
        var data = v
        angular.forEach(v.encounters, (enc) => {
            let url2 = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/encounter/" + enc.uuid
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
                   var obs = display.split(':');
                  data.doctor = obs[0]
               }
            })
        })
        \$scope.values.push(data) 
    })
})
})
patient.filter('startFrom', function() {
    return function(input, start) {
        start = +start; //parse to int
        return input.slice(start);
    }
});
</script>
