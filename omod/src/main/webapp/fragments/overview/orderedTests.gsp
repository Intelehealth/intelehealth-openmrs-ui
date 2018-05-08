<div id="orderedTests" class="long-info-section" ng-controller="OrderedTestsSummaryController">
	<div class="info-header">
		<i class="icon-beaker"></i>
		<h3>Prescribed Tests</h3>
	</div>
	<div class="info-body" ng-cloak>{{test}}
  <br/>
			<input ng-show="visitStatus" type="text" ng-model="addMe" uib-typeahead="test for test in testlist | filter:\$viewValue | limitTo:8" class="form-control">
			<button ng-show="visitStatus" type="button" class='btn btn-default' ng-click="addAlert()">Add Test</button>
			<p>{{errortext}}</p>
			<br/>
			<br/>
			<div uib-alert ng-repeat="alert in alerts" ng-class="'alert-' + (alert.type || 'info')" close="closeAlert(\$index)">{{alert.msg}}</div>
	</div>
  <br>
</div>

<script>
var app = angular.module('orderedTestsSummary', ['recentVisit', 'ngAnimate', 'ngSanitize', 'EncounterModule']);

app.factory('OrderedTestsSummaryFactory3', function(\$http){
  var testurl = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/concept/" + window.constantConfigObj.conceptTests;
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

app.controller('OrderedTestsSummaryController', function(\$scope, \$http, \$timeout, EncounterFactory, OrderedTestsSummaryFactory3, recentVisitFactory) {
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

											if(encounter.match("REQUESTED TESTS") !== null) {
											\$scope.alerts.push({"msg":v.display.slice(17,v.display.length), "uuid": v.uuid});

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



  var promiseTests = OrderedTestsSummaryFactory3.async().then(function(d){
	return d;
  });

  promiseTests.then(function(x){
	\$scope.testlist = x;
  })

  \$timeout(function () {
                \$scope.addAlert = function() {
                        \$scope.errortext = "";
                        if (!\$scope.addMe) {
                                \$scope.errortext = "Please enter text.";
                                return;
                        }
    			if (\$scope.alerts.indexOf(\$scope.addMe) == -1){
    				\$scope.alerts.push({msg: \$scope.addMe})
    				var url2 = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/obs";
    				\$scope.json = {
         				concept: window.constantConfigObj.conceptRequestedTests,
         				person: patient,
         				obsDatetime: date2,
         				value: \$scope.addMe,
         				encounter: EncounterFactory.encounterValue
        			}
              console.log(\$scope.json);
    				\$http.post(url2, JSON.stringify(\$scope.json)).then(function(response){
        				if(response.data) {
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
  		};

	  		\$scope.closeAlert = function(index) {
	  			if (\$scope.visitStatus) {
		    		var deleteurl = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/obs/" + \$scope.alerts[index].uuid + "?purge=true";
					\$http.delete(deleteurl).then(function(response){
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
