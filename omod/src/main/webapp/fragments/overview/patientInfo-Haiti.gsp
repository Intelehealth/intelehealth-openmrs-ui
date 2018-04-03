<div id="patientInfo" class="long-info-section" ng-controller="patientInfoController" ng-show = 'return'>
	<div class="info-header">
		<i class="icon-book"></i>
		<h3>Patient Information</h3>
	</div>
	<div class="info-body">
	<table ng-cloak>
									<td style="border:none">
											Prison Name: {{var2}}
									</td>
									<td style="border:none">
											Department: {{var4}}
									</td>
									<td style="border:none">
											Commune: {{var5}}
									</td>
									<td style="border:none">
											Cell Number: {{var1}}
									</td>
									<td style="border:none">
											Patient Status: {{var3}}
									</td>
</tr>
	</table>
	</div>
    <div>
        <a href="#" class="right back-to-top">Back to top</a>
    </div>
</div>
<script>
var app = angular.module('patientInfo', ['ngAnimate', 'ngSanitize', 'EncounterModule']);
app.controller('patientInfoController', function(\$scope, \$http, EncounterFactory) {
	  var patient = "${ patient.uuid }";
		var promise1 = EncounterFactory.locationService().then(function(d){
			\$scope.data4 = d;
			return \$scope.data4;
		});

		promise1.then(function(x){
			\$scope.location = \$scope.data4;
			angular.forEach(\$scope.location, function(value, key) {
				var location = value.country;
				if(location === "Haiti")
				\$scope.return = true;
				else \$scope.return = false;
			});
		});
	  var testurl = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/person/" + patient;
	 \$http.get(testurl).then(function(response){
			angular.forEach(response.data.attributes, function(v, k){
				var encounter = v.display;
				if(encounter.match("Cell Number") !== null) {
				\$scope.var1 = v.display.slice(13,v.display.length);
				}
				else if(encounter.match("Prison Name") !== null) {
				\$scope.var2 = v.display.slice(13,v.display.length);
				}
				else if(encounter.match("Patient Status") !== null) {
				\$scope.var3 = v.display.slice(16,v.display.length);
				}
				else if(encounter.match("Department") !== null) {
				\$scope.var4 = v.display.slice(12,v.display.length);
				}
				else if(encounter.match("Commune") !== null) {
				\$scope.var5 = v.display.slice(9,v.display.length);
				}
			});
	 });
});
</script>
