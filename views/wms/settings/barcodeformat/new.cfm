<cfoutput>
<section class="section">
	<div class="container">
		<div class="content">
			<header class="bd-header">
				<div class="bd-header-titles">
					<h1 class="title">Barcode Format</h1>
					<h5 class="subtitle">Create a new record</h5>
				</div>
			</header>
		</div>
	</div>
</section>
<div class="hero">
	<div class="container">
		<div class="columns">
			<div class="column is-half">
				<div class="form">
					#startFormTag(route="wmsSettingsBarcodeformatIndex", method="post", multipart=true, name="barcodeFormat")#
						<div class="field">
							<label class="label">Name</label>
							<div class="control has-icons-left has-icons-right">
						  		#textField(type="text", class="input", placeholder="Enter name",objectName="barcodeformat", property="name", label=false)#
								<span class="icon is-small is-left">
						  			<i class="fas fa-tag"></i>
								</span>
							</div>
						</div>
						<div class="field">
						  <label class="label">Type</label>
						  <div class="control">
						    <div class="select">
						    	#select(objectName="barcodeformat", property="type", options=format, label=false)#
						    </div>
						  </div>
						</div>
						<div class="field">
							<label class="label">Target</label>
							<div class="control has-icons-left has-icons-right">
						  		#textField(type="text", class="input", placeholder="Enter bartender file name",objectName="barcodeformat", property="target", label=false)#
								<span class="icon is-small is-left">
						  			<i class="fas fa-crosshairs"></i>
								</span>
							</div>
						</div>
						<div class="field">
							<label for="division" class="label">Division</label>
							<div class="control">
								<div class="select">
									#select(objectName="barcodeformat", property="division", options=SESSION.wms.allowed_divisions, valueField="id", textField="name", label=false)#
								</div>
							</div>
						</div>
						<div class="field">
						  <label class="label">Description</label>
						  <div class="control">
						    #textArea(objectName="barcodeformat", property="description", class="textarea", placeholder="Enter anything. Remarks, etc.", label=false)#
						  </div>
						</div>
						<div class="field">
							<label class="label">Upload New Image Preview</label>
							<div class="file is-info has-name is-fullwidth">
							  <label class="file-label">
							    #fileFieldTag(name="image_preview", class="file-input", id="form_image", accept=".jpg,.png", argumentCollection= {'ref' : "filefield", "@change" : "showFile" }, label=false)#
							    <span class="file-cta">
							      <span class="file-icon">
							        <i class="fas fa-upload"></i>
							      </span>
							      <span class="file-label">
							        Choose a file
							      </span>
							    </span>
							    <span class="file-name">{{ filename }}</span>
							  </label>
							</div>
							<a class="is-link has-text-right" v-show="filename" @click="clearFile()">Click here to clear the file</a>
						</div>

						<div class="field is-grouped is-grouped-right">
							<div class="control">
								#submitTag(class="button is-link", value="Create")#
							</div>
							<div class="control">
								#linkTo(route="wmsSettingsBarcodeformatIndex", class="button is-text", text="Back")#
							</div>
						</div>
					#endFormTag()#
				</div>
			</div>
		</div>
	</div>
</div>
</cfoutput>