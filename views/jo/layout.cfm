<cfparam name="title" type="string">

<cfoutput>
	<!DOCTYPE html>
	<html>
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta http-equiv="Pragma" content="no-cache">
		<meta http-equiv="Expires" content="-1">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<title>#title#</title>
		#styleSheetLinkTag("bulma.min")#
		#styleSheetLinkTag("app")#
		#styleSheetLinkTag("animate_3_7_0")#
		#javaScriptIncludeTag("vue_2_6_2")#
		#javaScriptIncludeTag("underscore_1_9_1.min")#
		#javaScriptIncludeTag("fontawesome_5_3_1")#
		#javaScriptIncludeTag("axios_0_18.min")#
		#javaScriptIncludeTag("bluebird_3_3_5.min")#
		#includePartial("head")#
		<!--- <script type="text/javascript">
			var ua = window.navigator.userAgent; 
			var msie = ua.indexOf("MSIE "); 
			if (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./)) document.write('<script src=../../../javascripts/bluebird_3_3_5.min.js><\/scr'+'ipt>'); 
		</script> --->
	</head>
	<body class="has-navbar-fixed-top">
		<div id="app">
			#includePartial("/jo/nav")#
			#includePartial("/jo/alert")#
			#includeContent()#
			#includePartial("/jo/footer")#
		</div>
		#includePartial("js")#
		#javascriptIncludeTag(controllerJS)#
	</body>
	</html>
</cfoutput>
