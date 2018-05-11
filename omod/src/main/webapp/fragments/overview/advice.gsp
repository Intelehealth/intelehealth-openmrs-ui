<div id="advice" class="long-info-section" ng-controller="AdviceSummaryController">
	<div class="info-header">
		<i class="icon-comments"></i>
		<h3>Medical Advice</h3>
	</div>
	<div class="info-body" ng-cloak>
	<br>
		<input ng-show="visitStatus" type="text" ng-model="addMe" uib-typeahead="test for test in advicelist | filter:\$viewValue | limitTo:8" class="form-control">
		<button ng-show="visitStatus" type="button" class='btn btn-default' ng-click="addAlert()">Add Advice</button>
		<p>{{errortext}}</p>
		<br><br>
		<div uib-alert ng-repeat="alert in alerts" ng-class="'alert-' + (alert.type || 'info')" close="closeAlert(\$index)">{{alert.msg}}</div>
	</div>
  <br>
</div>

<script>
var app = angular.module('adviceSummary', ['recentVisit', 'ngAnimate', 'ngSanitize', 'EncounterModule']);

app.factory('AdviceSummaryFactory3', function(\$http){
  var testurl = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/concept/" + window.constantConfigObj.conceptMedicalAdvice1;
  return {
    async: function(){
      return \$http.get(testurl).then(function(response){
        var data = [];
        angular.forEach(response.data.answers, function(value, key){
          data.push(value.display);
        });
        return data;
      });
    }
  };
});

app.controller('AdviceSummaryController', function(\$scope, \$http, \$timeout, EncounterFactory, AdviceSummaryFactory3, recentVisitFactory) {
\$scope.alerts = [];
\$scope.respuuid = [];
var _selected;
var patient = "${ patient.uuid }";
var date2 = new Date();

var path = window.location.search;
var i = path.indexOf("visitId=");
var visitId = path.substr(i + 8, path.length);
\$scope.visitEncounters = [];
\$scope.visitObs = [];
\$scope.visitNoteData = [];
\$scope.visitNotePresent = true;
\$scope.visitStatus = false;
\$scope.encounterUuid = "";
recentVisitFactory.fetchVisitEncounterObs(visitId).then(function(data) {
						\$scope.visitDetails = data.data;
							if (\$scope.visitDetails.stopDatetime == null || \$scope.visitDetails.stopDatetime == undefined) {
								\$scope.visitStatus = true;
							}
							else {
								\$scope.visitStatus = false;
							}
						\$scope.visitEncounters = data.data.encounters;
						if(\$scope.visitEncounters.length !== 0) {
						\$scope.visitNotePresent = true;
							angular.forEach(\$scope.visitEncounters, function(value, key){
								var isVital = value.display;
								if(isVital.match("Visit Note") !== null) {
									\$scope.encounterUuid = value.uuid;
									var encounterUrl =  "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/encounter/" + \$scope.encounterUuid;
									\$http.get(encounterUrl).then(function(response) {
										angular.forEach(response.data.obs, function(v, k){
											var encounter = v.display;
											if(encounter.match("MEDICAL ADVICE") !== null) {
											\$scope.alerts.push({"msg":v.display.slice(16,v.display.length), "uuid": v.uuid});
											}
										});
									}, function(response) {
										\$scope.error = "Get Encounter Obs Went Wrong";
								    	\$scope.statuscode = response.status;
								    });
								}
							});
						}
						else {
							\$scope.visitNotePresent = false;
						}
						}, function(error) {
						console.log(error);
					});

  var promiseAdvice = AdviceSummaryFactory3.async().then(function(d){
        return d;
  });

  promiseAdvice.then(function(x){
        \$scope.advicelist = x;
  })

  \$timeout(function () {
      \$scope.addAlert = function() {
				if(EncounterFactory.encounterValue) {

        		\$scope.errortext = "";
        		if (!\$scope.addMe) {
                		\$scope.errortext = "Please enter text.";
                		return;
        		}
        		if (\$scope.alerts.indexOf(\$scope.addMe) == -1){
                		\$scope.alerts.push({msg: \$scope.addMe})
				var url2 = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/obs";
                        	\$scope.json = {
                        		concept: window.constantConfigObj.conceptMedicalAdvice2,
                                	person: patient,
                                	obsDatetime: date2,
                                	value: \$scope.addMe,
                                	encounter: EncounterFactory.encounterValue
                        	}
                        	\$http.post(url2, JSON.stringify(\$scope.json)).then(function(response){
                        		if(response.data){
                                		\$scope.statuscode = "Success";
                                		angular.forEach(\$scope.alerts, function(v, k){
											var encounter = v.msg;
											if(encounter.match(\$scope.addMe) !== null) {
											v.uuid = response.data.uuid;
											}
										});
										\$scope.addMe = "";
                                }
                        	}, function(response){
                        		\$scope.statuscode = "Failed to create Obs";
                        	});
        		}
					}
					else {
						alert("If there are multiple reloads, please contact system admin.");
						window.location.reload(true);
					}

};
  		\$scope.closeAlert = function(index) {
	  		if (\$scope.visitStatus) {

				\$scope.deleteurl = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/obs/" + \$scope.alerts[index].uuid + "?purge=true";
	                	\$http.delete(\$scope.deleteurl).then(function(response){
			                \$scope.alerts.splice(index, 1);
			        		\$scope.errortext = "";
	                		\$scope.statuscode = "Success";
	                	}, function(response){
	                		\$scope.statuscode = "Failed to delete Obs";
	                	});
	        }
        };
  }, 5000);
});
</script>

<script>
</script>
