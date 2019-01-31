<div id="interaction" class="long-info-section" ng-controller="InteractionController">
	<div class="info-header">
		<i class="icon-phone"></i>
		<h3>Patient Interaction</h3>
	</div>
    <div class="info-body">
    <div>Have you spoken with the patient directly?</div>
    <div id = "interaction" ng-cloak>
		<br/>
		<input type="radio" name="interaction" id="1"> Yes
        &nbsp&nbsp
		<input type="radio" name="interaction" id="2"> No
        <button type="button"  ng-click ='interaction()' style=" margin-left: 30px;" ng-show = "alerts.length == 0">Select</button>

        </div>
        <div uib-alert ng-repeat="alert in alerts" style = "margin: 10px 7px;" ng-class="'alert-' + (alert.type || 'info')">{{alert.msg}}</div>
        </div>
</div>

<script>
var app = angular.module('Interaction', ['ngAnimate', 'ngSanitize']);

app.controller('InteractionController', function(\$scope, \$http, \$timeout) {
    \$scope.interaction = function() {
        if (document.getElementById('1').checked) {
            insert('Yes')
        }
        if (document.getElementById('2').checked) {
            insert('No')
        }
    }

    \$scope.alerts = [];
    var url = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/visit/" + visitId + "/attribute"
        \$http.get(url).then(function(response){
            if (response.data.results.length != 0){
                var text = response.data.results[0].display;
                \$scope.alerts.push({"msg":text.slice(20, text.length)});
            }
        })

    function insert(value){
        var path = window.location.search;
        var i = path.indexOf("visitId=");
        var visitId = path.substr(i + 8, path.length);
        var url = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/visit/" + visitId + "/attribute"
        \$http.get(url).then(function(response){
            if (response.data.results.length != 0){
            }
            else {
                    var json = {
                    "attributeType": window.constantConfigObj.patientInteraction,
                    "value": value
                    };
                \$http.post(url, JSON.stringify(json)).then(function(response){
                \$scope.alerts.push({msg: value});
                })
            }
        })
        
    }
})
</script>