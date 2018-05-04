<%
    ui.includeJavascript("intelehealth", "diagnoses/diagnoses.js")
%>

<% /* This is an underscore template, since I dont know how to use angular templates programmatically */ %>

<script ng-show="visitStatus" type="text/template" id="autocomplete-render-item">
    <span class="code">
        {{ if (item.code) { }}
        {{- item.code }}
        {{ } else if (item.concept) { }}
        ${ui.message("coreapps.consult.codedButNoCode")}
        {{ } else { }}
        ${ui.message("coreapps.consult.nonCoded")}
        {{ } }}
    </span>
    <strong class="matched-name">
        {{- item.matchedName }}
    </strong>
    {{ if (item.preferredName) { }}
    <span class="preferred-name">
        <small>${ui.message("coreapps.consult.synonymFor")}</small>
        {{- item.concept.preferredName }}
    </span>
    {{ } }}
</script>
<div id="diagnosis" class="long-info-section" ng-controller="DiagnosesController">
        	<div class="info-header">
        		<i class="icon-diagnosis"></i>
        		<h3>Diagnoses</h3>
        	</div>
        	<div class="info-body" ng-cloak>
        		<br/>
        		<input type="text" ng-model="addMe1" autocomplete itemFormatter="autocomplete-render-item"  class="form-control">
        		<button type="button" class='btn btn-default' ng-click="addAlert()">Add Diagnosis</button>
        		<p>{{errortext}}</p>
            <br/>
        		<br/>
            <div id = "diagnosis-radioclass">
            <label id = "diagnosis">
  						<input type="radio" value="Primary" ng-model="prisec">
  						  Primary
					  </label>
            <label id = "diagnosis" style = " margin-left: 30px !important; ">
      				<input type="radio" value="Secondary" ng-model="prisec">
      				  Secondary
  		      </label>
            <br/>
            <label id = "diagnosis">
              <input type="radio" value="Confirmed" ng-model="confirm">
                Confirmed
            </label>
            <label id = "diagnosis">
              <input type="radio" value="Certain" ng-model="confirm">
                Certain
            </label>
          </div>
          <br>
        		<div uib-alert ng-repeat="alert in alerts" ng-class="'alert-' + (alert.type || 'info')" close="closeAlert(\$index)">{{alert.msg}}</div>
        	</div>
        </div>
            <br>
        </div>
        <br>
<script>
var app = angular.module('diagnoses', ['recentVisit', 'ngAnimate', 'ngSanitize']);
    app.factory('DiagnosisFactory1', function(\$http, \$filter){
      var patient = "${ patient.uuid }";
      var date = new Date();
      date = \$filter('date')(new Date(), 'yyyy-MM-dd');
      var url = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/encounter";
          url += "?patient=" + patient;
          url += "&encounterType=" + window.constantConfigObj.encounterTypeVisitNote;
      return {
        async: function(){
          return \$http.get(url).then(function(response){
            return response.data.results;
          });
        }
      };
    });
    app.directive('autocomplete', function(\$compile, \$timeout, \$http, DiagnosisFactory1) {
        return function(scope, element, attrs) {
            // I don't know how to use an angular template programmatically, so use an underscore template instead. :-(
            var itemFormatter = _.template(\$('#' + attrs.itemformatter).html());
            element.autocomplete({
                source: emr.fragmentActionLink("coreapps", "diagnoses", "search"),
                response: function(event, ui) {
                    var query = event.target.value.toLowerCase();
                    var items = ui.content;
                    // remove any already-selected concepts, and look for exact matches by name/code
                    var exactMatch = false;
                    for (var i = items.length - 1; i >= 0; --i) {
                        items[i] = diagnoses.CodedOrFreeTextConceptAnswer(items[i]);
                        if (!exactMatch && items[i].exactlyMatchesQuery(query)) {
                            exactMatch = true;
                        }
                        if (scope.encounterDiagnoses.diagnosisWithConceptId(items[i].conceptId)) {
                            items.splice(i, 1);
                        }
                    }
                    if (!exactMatch) {
                        items.push(diagnoses.CodedOrFreeTextConceptAnswer(element.val()))
                    }
                },
                focus: function( event, ui ) {
                    element.val(ui.item.matchedName);
                    return false;
                },
                select: function( event, ui ) {
                    scope.\$apply(function() {
                        scope.encounterDiagnoses.addDiagnosis(diagnoses.Diagnosis(ui.item));
                        var topost = diagnoses.Diagnosis(ui.item);
                        \$timeout(function () {
                                var promise = DiagnosisFactory1.async().then(function(d){
                                        var length = d.length;
                                        if(length > 0) {
                                                angular.forEach(d, function(value, key){
                                                        scope.data = value.uuid;
                                                });
                                        }
                                        return scope.data;
                                });
        scope.patient = "${ patient.uuid }";
        scope.addMe1 = topost.diagnosis.matchedName;
				promise.then(function(x){
          scope.addAlert = function(){
            scope.errortext = '';
            var alertText = '';
            var date2 = new Date();
            scope.mycolor = 'white';
            if(!scope.addMe1 | !scope.prisec | !scope.confirm){
              scope.errortext = 'Please enter text.';
              if(!scope.addMe1){
                scope.mycolor = '#FA787E';
              }
              return;
            }
            else{
              alertText = scope.addMe1 + ':' + scope.prisec + ' & ' + scope.confirm;
            }
            if(scope.alerts.indexOf(scope.addMe) == -1) {
              scope.alerts.push({msg:alertText})
              var url2 = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/obs";
              scope.json = {
                      concept: window.constantConfigObj.conceptDiagnosis,
                      person: scope.patient,
                      obsDatetime: date2,
                      value: alertText,
                      encounter: x
              }
              scope.prisec = 'Primary';
              scope.confirm = '';
              \$http.post(url2, JSON.stringify(scope.json)).then(function(response){
                      if(response.data)
                              scope.statuscode = "Success";
                              angular.forEach(scope.alerts, function(v,k){
                                var encounter = v.msg;
                                if(encounter.match(scope.addMe1) !== null){
                                  v.uuid = response.data.uuid;
                                }
                              });
                              scope.addMe1 = '';
                }, function(response){
                        scope.statuscode = "Failed to create Obs";
              });
            }
          };
      });
    }, 1000);
                    });
                    return false;
                }
            })
            .data( "autocomplete" )._renderItem = function( ul, item ) {
                var formatted = itemFormatter({item: item});
                return jq('<li>').append('<a>' + formatted + '</a>').appendTo(ul);
            };
        }
    });
    app.controller('DiagnosesController', [ '\$scope', '\$http' , '\$timeout', 'DiagnosisFactory1', 'recentVisitFactory',
        function DiagnosesController(\$scope, \$http, \$timeout, DiagnosisFactory1, recentVisitFactory) {
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
        											if(encounter.match("TELEMEDICINE DIAGNOSIS") !== null) {
        											\$scope.alerts.push({"msg":v.display.slice(23,v.display.length), "uuid": v.uuid});
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
            \$timeout(function () {
                \$scope.test1 = 0;
                \$scope.test2 = 0;
                \$scope.diagnosesToPost = [];
                \$scope.encounterDiagnoses = diagnoses.EncounterDiagnoses();
                \$scope.priorDiagnoses = diagnoses.EncounterDiagnoses();
                \$scope.addPriorDiagnoses = function() {
                        \$scope.encounterDiagnoses.addDiagnoses(angular.copy(\$scope.priorDiagnoses.getDiagnoses()));
                }
                \$scope.removeDiagnosis = function(diagnosis) {
                        \$scope.encounterDiagnoses.removeDiagnosis(diagnosis);
                        \$scope.test2 = \$scope.respuuid;
                        \$scope.test3 = {name:diagnosis.diagnosis.matchedName,confirmed:diagnosis.confirmed,primary:diagnosis.primary};
                };
                \$scope.valueToSubmit = function() {
                        return "[" + _.map(\$scope.encounterDiagnoses.diagnoses, function(d) {
                                return d.valueToSubmit();
                        }).join(", ") + "]";
                };


		\$scope.closeAlert = function(index) {
			if (\$scope.visitStatus) {
			\$scope.myColor = "white";
			\$scope.deleteurl = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/obs/" +
          \$scope.alerts[index].uuid + "?purge=true";
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
        }
    ]);

</script>
