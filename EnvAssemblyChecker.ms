
try(closeRolloutFloater RolloutFloaterTemplate) catch()

--ROLLOUT 1: Restore Dummy Section
rollout DummyRolloutTemplate "Restore Dummy"
(
	--Button 1 Create a new dummy
	button DummyNew "Create New Dummy"
	--Button 2 Rename the main dummy
	button DummyRename "Rename Main Dummy"	
	--Button 3 Give the position 0,0,0 to dummy o other objects
	button DummyPosition "Position [0,0,0]"
	--Button 4 Give the rotation 0,0,0 to dummy or other objects
	button DummyRotate "Rotate [0,0,0]"
	--Button 5 Give the scale 1,1,1 to dummy or other objects
	button DummyScale "Scale [100,100,100]"
	

	--Action button 1 : Create a new dummy and locate it in  pos:[0,0,0]
	on DummyNew pressed do
	(
		Dummy pos:[0,0,0] isSelected:on
	)
	
	--Action button 2 : Rename the selected dummy with the name of the current file  (Main Dummy).
	on DummyRename pressed do    
	(	
		filename = getFilenameFile maxFilename
		for i in $selection do
		(
			i.name = filename + "_Dummy"
		)
		
	)
	
	--Action of button 3 : Restore the selected dummy to position  0,0,0
	on DummyPosition pressed do
	(
		--for i in helpers do
		--(
			--select helpers
			for i in $selection  do
			(
				$selection.pos.x = 0 
				$selection.pos.y = 0 
				$selection.pos.z = 0
				
			)
		--)
	)
	
	--Action button 4 Restore the selected dummy to rotation  0,0,0
	on DummyRotate pressed do 
	(
		for i in $selection  do
		(
			$selection.rotation.x = 0
			$selection.rotation.y = 0
			$selection.rotation.z = 0
		)		
	)
	
	--Action of button 5 : Restore the selected dummy to scale 1,1,1
	on DummyScale pressed do
	(
		for i in $selection  do
		(
			$selection.scale.x = 1
			$selection.scale.y = 1
			$selection.scale.z = 1
		)
	)
	
)

rollout VRayProxyRolloutTemplate "Ensure VRayProxy Geometry"
(
	--Button 1
	button VrayProxySelection "Select VrayProxy Geoemtry"
	--Button 2
	button MeshSelection "Select Non-VRayProxy Geometry"
	--Button 3
	button MeshConvertToVRayProxy "Convert Meshes to VRayProxy"
	
	--Action of button 1 : Select all the objects in scene that are VrayProxy, and print the names and the numbers of this objects.
	on VrayProxySelection pressed do
	(
		clearSelection()
		count =0
		print "  [Name of VrayProxy Geometry]:" --Print the names of the objects
		for i in geometry where classof i == VrayProxy do 
			(
				selectmore i
				print i.name
				count += 1
			)
		print "  [Number of VrayProxy Geometry]: "	--Print the number of this objects
		print count
	)
	
	--Action of button 2 : Select all the objects in scene that are Not VrayProxy, and print the names and the numbers of this objects.
	on MeshSelection pressed do
	(
		clearSelection()
		count =0
		print "  [Name of Non-VrayProxy Geometry]:"  --Print the names of the objects
		for i in geometry where classof i != VrayProxy do 
			(
				selectmore i
				print i.name
				count += 1
			)
		print "  [Number of Non-VrayProxy Geometry]: "	 --Print the number of this objects
		print count
	)
	
	--Action of button 3 : Convert the polymeshes geoemtry to VrayProxy (Their names must be right according to pipeline)
	on MeshConvertToVRayProxy pressed do
	(
		clearSelection() --Deselect all objects in scene
		
		geo_list = (for i in geometry where classof i != VrayProxy collect i.name) --Create an array of names of non-vrayproxy geometry
		
		for i in 1 to geo_list.count do --Based of this array it´s will extract the info needed.
		(
	
			--We get info of our mesh
			geo_name = geo_list[i] --Name  of the current mesh object
			filepath = maxFilePath --Path of our scene max where we are working
			
			--LLAMAR A UNA FUNCION QUE REGRESE LA VERSION MAS ALTA CON REFERENCIA DEL NOMBRE Y PARTH DEL ARCHIVO
			
			vray_path = filepath + geo_name + "v001.vrmesh" --Put together the filepath and the name of current mesh, thus we create a new path for our new vrayproxy
			geo_node = getNodeByName geo_name --Select the object specified by the name
			
			--Get coordenates from current mesh object as a reference for our new vrayproxy
			vray_position_x = geo_node.transform.pos.x  --Position X
			vray_position_y = geo_node.transform.pos.y  --Position Y
			vray_position_z = geo_node.transform.pos.z  --Position Z
			
			--Create the new VRayProxy using the collected info inside of a new variable
			new_vrayproxy = (VrayProxy filename:vray_path pos: [vray_position_x, vray_position_y, vray_position_z ] display: 4)
			new_vrayproxy.name = geo_name --Rename our new object with the name of the current mesh
			
			filename = getFilenameFile maxFilename --Get the name of our scene max where we are working
			for h in helpers where h.name == (filename + "_Dummy") do --Searching the right dummy by name
			(
				select h --Select the right dummy
				new_vrayproxy.parent = h --Parenting the new VrayProxy with the main dummy
			)

			if geo_node != VrayProxy do (delete geo_node) --Delete the replaced geometry Non-VrayProxy
	
			clearSelection() --Deselect all in the scene

		)
		
	)
	
)

rollout SortSceneTemplate "Sort Scene"
(
	--Button 1
	button DeleteDummies "Delete Empty Dummies"
	
	--Button 2
	button BaseNameVrayProxy "Get Base Name to VrayProxy From Source"
	
	--Button 3
	button InstantiateObjects "Instantiate Objects"
	
	--Button 4
	button LastVersion "Charge Last Version Of VrayProxy Source"
	
	--Action 1 : Delete the empty dummies of the scene
	on DeleteDummies pressed do
	(
		dummy_delete = (for i in helpers where i.children.count == 0 collect i) --Make an array of empty dummies
		delete dummy_delete --Delete the collection of this empty objects
		clearSelection() --Deselect all objects of the scene
	)
	
	--Action 2 : Rename only the VrayProxy objects based from filenames source
	on BaseNameVrayProxy pressed do
	(
		for i in geometry where classof i == VrayProxy do i.display =2 --Create a flag for diference between processed objects with the propertie DISPLAY
			
		path_names = (for i in geometry where classof i == VrayProxy collect i.filename) --Create an array with paths of the objects
		for i in 1 to path_names.count do --According to before array
		(
			for o in geometry where o.filename == path_names[i] do --If the objects meet with the right names
			(
				if o.display != 4 do --Using our before flag DISPLAY
				(
					selectmore o --Select object that meet with all requirement
					token = filterString path_names[i] "\\"  --Create a new array with elements of path
					name_object = token [token.count] --Get the name of the object among all fields of information
					num_substring = name_object.count - 11 --Calculing the number of elements what we need of the string
					name_object = substring name_object 1 num_substring  --New string from before
					o.name = name_object  --Assign the new name
					o.display =4  --Changing the flag value
				)
				
			)
			
		)
	)
	
	--Action 3 : Instancing the vrayproxy objects
	on InstantiateObjects pressed do
	(
		for i in geometry where classof i == VrayProxy do --From all vrayproxy objects
		(
			source = i  --Obtain the source value
			to_instance = "$"+ i.name +"*" --Calculate the to_instance value
			instanceReplace (execute to_instance)  source --Using the function instanceReplace with our 2 factors
		)
	)
	
	--Action 4
	on LastVersion pressed do
	(
		--Get an array with names of all geometry class VrayProxy from scene
		names = (for i in geometry  where classof i == VrayProxy collect i.name)

		--Declare a new array that it will contain our unique names of vrayproxys
		new_names = #()

		--We start a loop
		for i in 1 to names.count do
		(
			compare = names[i] --Assign the value of camparation in turn
			exist = false --Inicialize our flag
			
			--Evaluate if i is our first element
			if  i == 1 do
			(
				new_names [i] = compare --Our campare value is directly assign to new_names array in the position 1
			)
			
			--Evaluate if  i is not first element
			if i > 1 do 
			(
				for n in 1 to new_names.count do --Compare our compare value vs our new_names array elements
				(
					if compare == new_names[n] do --Is our compare value equal to some element of new_names array?
					(
						exist = true --If this value exist already, our flag change your value.
					)
				)
				
				if exist == false do --Evaluate the final result
				( 
					new_names [i] = compare	--If our compare value non-exist in the current values of new_names array, this is added.
				)	
			)
		)	
		new_names --At the end , we got the follow unique names from vrayproxy of our scene

		--Then we get this loop where we will get the collection of version vrmesh of each prop
		for i in 1 to new_names.count do
		(
			filepath = maxFilePath --Directory path
			reference_name = new_names[i] + "*" --Name reference of files
			files_collection = getfiles (filepath + reference_name + "*.vrmesh") --search the files
			
			--Printing the path collection by objects names
			print "-----------------"
			print "Collection "+ (i as string) + ":"
			print files_collection.count
			print "-----------------"
			
			
			version = #() --Inicilizing an array of versions
			for n in 1 to files_collection.count do --Making the list of versions
			(
				path_separate = filterString files_collection [n] "\\" --Separing path info in array
				name_file = path_separate[path_separate.count] --Get the name of our referenced object
				start = findstring name_file "v0" --Obtaining the number of substraing
				version[n] = substring name_file  (start + 1)  3 ---Version Array with the substred characters
				
				--Print the number of existing versions
				print "Number of versions: "
				print version[n]
			)
			
			higher = (version [1] as integer) --Inicilizing higher number by collection
				
			--Searching the higher of each collection
			for o in 1 to version.count do
			(	
				if higher < (version[o] as integer) do --Processing number
				(
					higher = (version[o] as integer) 
				)
			)
			
			--The higher version by collection
			print "The higher version by collection: " 
			print  higher
				
			--Returning the result information
			last_version = higher as string --Our last version 
			names = new_names [i] --reference name by object
			geonode_vrmesh = getNodeByName names --Select the object to modify
			files_path = maxFilePath --Get the path of file
			
			--Updating the filenames of vrayproxy to last version
			--If higher has a digit
			if higher > 0 and higher < 10 do
			(
				update_path = files_path + names + "v00" + last_version + ".vrmesh"
				geonode_vrmesh.filename = update_path
			)
			--If higher has 2 digit
			if higher > 9 and higher < 100 do
			(
				update_path = files_path + names+ "v0" + last_version + ".vrmesh"
				geonode_vrmesh.filename = update_path
			)
			--If higher has 3 digit
			if higher >99 and higher < 1000 do
			(
				update_path = files_path + names + "v" + last_version + ".vrmesh"
				geonode_vrmesh.filename = update_path
			)

		)
		
	)
	
)

RolloutFloaterTemplate = newrolloutfloater "EnvAssembly Checker" 245 415
addrollout DummyRolloutTemplate RolloutFloaterTemplate
addrollout VRayProxyRolloutTemplate RolloutFloaterTemplate
addrollout SortSceneTemplate RolloutFloaterTemplate


