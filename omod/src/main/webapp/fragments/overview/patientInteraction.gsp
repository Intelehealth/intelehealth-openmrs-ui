<div id="interaction" class="long-info-section" ng-controller="InteractionController">
	<div class="info-header">
		<i class="icon-phone"></i>
		<h3>Patient Interaction</h3>
	</div>
    <div class="info-body">
    <div>Have you spoken with the patient directly?</div>
    <div id = "interaction" ng-cloak>
		<br/>
		<input type="radio" name="interaction" id="1" value="Yes"> Yes
        &nbsp&nbsp
		<input type="radio" name="interaction" id="2" value="No"> No
        <button type="button"  ng-click ='interaction()' style=" margin-left: 30px;">Select</button>

        </div>
        </div>
</div>

<script>
var app = angular.module('Interaction', ['ngAnimate', 'ngSanitize']);

app.controller('InteractionController', function(\$scope, \$http, recentVisitFactory, EncounterFactory, \$timeout) {
    \$scope.interaction = function() {
        if (document.getElementById('1').checked) {
            console.log('hi')
        }
        if (document.getElementById('2').checked) {
            console.log('hello')
        }
    }
})
</script>