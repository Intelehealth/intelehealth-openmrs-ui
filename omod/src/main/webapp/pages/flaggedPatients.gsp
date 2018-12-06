<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeCss("intelehealth", "findrecord/findRecord.css")
    ui.includeCss("intelehealth", "flaticon/font/flaticon.css")
    ui.includeJavascript("intelehealth", "angularJS/angular.min.js")
%>
<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/referenceapplication/home.page' },
        { label: "${ ui.message("intelehealth.flaggedPatient.app.label")}"}
    ];
</script>

<h3>Flagged Patient</h3>

        
<div ng-app="patient">
<div class="info-body" ng-controller="patientController">
<div>Search <input type='text' ng-model='searchText'><div><br/>
<table>
    <th>SN</th>
    <th>Patient ID</th>
    <th>Flag</th>
    <th>Name</th>
    <th>Gender</th>
    <th>Age</th>
    <th>Location</th>
    <th>Last Seen</th>
<tr ng-repeat="visit in values | filter:searchText | startFrom:currentPage*pageSize | limitTo:pageSize">
    <td>{{((currentPage)*(pageSize))+\$index + 1}}</td>
    <td>{{visit.patient.identifiers[0].identifier}}</td>
    <td><span class="flaticon-danger"></span></td>
    <td><a href='/openmrs/intelehealth/intelehealthPatientDashboard.page?patientId={{visit.patient.uuid}}'>{{visit.patient.person.display}}</a></td> 
    <td>{{visit.patient.person.gender}}</td>
    <td>{{visit.patient.person.age}}</td>
    <td>{{visit.location.display}}</td>
    <td>{{visit.lastSeen}}<br>
    <small>{{visit.encounterDatetime | date: 'dd.MM.yyyy, HH:mm:ss'}}</small></td>
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
    \$scope.data = ''
    \$scope.currentPage = 0;
    \$scope.pageSize = 10;
    \$scope.values = [];
    \$scope.numberOfPages=function(){
         var myFilteredData = \$filter('filter')(\$scope.values,\$scope.searchText); 
        return Math.ceil(myFilteredData.length/\$scope.pageSize);                
    }
let url = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/visit/?&includeInactive=false&v=custom:(patient:(uuid,identifiers:(identifier),person:(display,gender,age)),location:(display),encounters:(uuid,display))"
\$http.get(url).then(function(response){
    angular.forEach(response.data.results, (v) => {
        angular.forEach(v.encounters, (encounter) => {
            var flagged = encounter.display
            if (flagged.match("Flagged")!== null) {
                let url2 = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/encounter/" + encounter.uuid + "?v=custom:(display,encounterDatetime,patient:(uuid,identifiers:(identifier),person:(display,gender,age)),location:(display))"
                \$http.get(url2).then(function(response){
                    var data = response.data
                    var lastSeen = response.data.display.split(' ');
                    data.lastSeen = lastSeen[0]
                    \$scope.values.push(data)
                })
                }   
            })
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
