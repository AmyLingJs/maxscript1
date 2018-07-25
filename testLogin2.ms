/*
 功能介绍
 在设置参考图片功能的基础上增加登录功能
 如果用户之前已经登录过则直接开始使用
 若未登录过则需要首先登录
 测试的插件名称为testPlugin1
*/
 MacroScript MiaoMiaoXue2
Tooltip:"设置参考图片"
category:"MiaoMiaoXue_Tool2"
(
	global objectLength
	global objectWidth
	global objectHeight
	function fn_findPlane thePlane = 
	(
		tp = for o in objects where matchpattern o.name pattern:thePlane collect o
		return tp
	)
	
	function fn_findAllPlanes = 
	(
		tp = for o in objects where matchpattern o.name pattern:"XX_BP_*" collect o
		return tp
	)
	
	function fn_createPlanes topPlane bottomPlane frontPlane backPlane leftPlane rightPlane =
	(
		planesArray = #(topPlane, bottomPlane, frontPlane, backPlane, leftPlane, rightPlane)
	
		--确定视图内已有的各个方向平面的数量 新创建的时候number+1
		existingTopPlanes = (fn_findPlane "XX_BP_TOP_*").count
		existingBottomPlanes = (fn_findPlane "XX_BP_BOTTOM_*").count
		existingFrontPlanes = (fn_findPlane "XX_BP_FRONT_*").count
		existingBackPlanes = (fn_findPlane "XX_BP_BACK_*").count
		existingLeftPlanes = (fn_findPlane "XX_BP_LEFT_*").count
		existingRightPlanes = (fn_findPlane "XX_BP_RIGHT_*").count
		
		for i = 1 to planesArray.count do
		(
			namePrefix = #("XX_BP_TOP_","XX_BP_BOTTOM_","XX_BP_FRONT_","XX_BP_BACK_","XX_BP_LEFT_","XX_BP_RIGHT_" )
			if planesArray[i] != "" then
			(
				imgFile = planesArray[i]
				tempMap = openBitMap imgFile
				tempMapWidth = tempMap.width
				tempMapHeight = tempMap.height
				ratio = tempMapWidth/tempMapHeight
				
				--有三个值
				--长宽高都有值
				if objectLength != undefined then objectLength = objectLength as float
				if objectWidth != undefined then objectWidth = objectWidth as float
				if objectHeight != undefined then objectHeight = objectHeight as float
			
				
				--只有一个值 
				
				--顶部 底部视图
				--只有长度
				if objectLength !=undefined and objectWidth ==undefined and objectHeight ==undefined
				    do objectWidth = objectLength * tempMapWidth/tempMapHeight
				print objectWidth
				--只有宽度
				if objectWidth !=undefined and objectLength == undefined and objectHeight ==undefined
					do objectLength = objectWidth*tempMapHeight/tempMapWidth
				
				--左侧 右侧视图
				--只有宽度
				if objectWidth !=undefined and objectHeight ==undefined and objectLength ==undefined
					do objectHeight = objectWidth * tempMapHeight/tempMapWidth
				--只有高度
				if objectHeight !=undefined and objectWidth == undefined and objectLength ==undefined
					do objectWidth = objectHeight * tempMapWidth/tempMapHeight
				
				--前 后视图
				--只有高度
				if objectHeight !=undefined and objectLength == undefined and objectWidth == undefined
					do objectLength = objectHeight * tempMapWidth/tempMapHeight
				--只有长度
				if objectLength !=undefined and objectHeight == undefined and objectWidth == undefined
					do objectHeight = objectLength*tempMapHeight/tempMapWidth
				
				
				--有两个值
				--有长度 宽度 需要在左右视图、前后视图的时候得到高度
				--左右视图
				if objectLength !=undefined and objectWidth !=undefined and objectHeight == undefined and i==5 or i==6
					do objectHeight = objectWidth * tempMapHeight/tempMapWidth
				--前后视图
				if objectLength !=undefined and objectWidth !=undefined and objectHeight == undefined and i==3 or i==4
					do objectHeight = objectLength * tempMapHeight/tempMapWidth
				
				
				--有长度 高度  需要在左右视图、顶底视图的时候得到宽度
				--左右视图
				if objectLength !=undefined and objectHeight!=undefined and objectWidth == undefined and i==5 or i==6
					do objectWidth = objectHeight * tempMapWidth/tempMapHeight
				--顶底视图
				if objectLength !=undefined and objectHeight!=undefined and objectWidth == undefined and i==1 or i==2
					do objectWidth = objectLength * tempMapWidth/tempMapHeight
				
				
				--有宽度 高度 需要在前后视图、顶底视图的时候得到长度
				--前后视图
				if objectWidth !=undefined and objectHeight !=undefined and objectLength ==undefined and i==3 or i==4
					do objectLength = objectHeight * tempMapWidth/tempMapHeight
				--顶底视图
				if objectWidth !=undefined and objectHeight !=undefined and objectLength ==undefined and i==1 or i==2
					do objectLength = objectWidth*tempMapHeight/tempMapWidth
				
				
				print objectLength
				print objectWidth

				imgPlane = plane name:(namePrefix[i] + (getfilenameFile imgFile)) length:(objectLength) width:(objectWidth) lengthsegs:1 widthsegs:1 mapCoords:true isselected:true
				
				
				imgPlane.renderable = off
				imgPlane.showFrozenInGray = off
				imgPlane.backfacecull = on
				
				imgPlane.wirecolor = color 88 177 26				
				imgMaterial = standard()
				imgMaterial.name = imgPlane.name
				imgMaterial.selfIllumAmount = 100
				
				imgTexture = bitmaptexture()
				imgTexture.bitmap = tempMap
				
				imgMaterial.diffuseMap = imgTexture
				imgPlane.material = imgMaterial
				imgMaterial.twoSided = on
				showTextureMap imgMaterial imgMaterial.diffuseMap on
				close tempMap
				
				
				
				
				
				case of
				(
					(i == 1):  -- top plane
						(
							print "imgPlane.max:"+imgPlane.max as string
							print "imgPlane.min:"+imgPlane.min as string
							imgPlane.length = objectLength
							imgPlane.width = objectWidth
							imgPlane.rotation = (eulerangles 0 0 0)
							imgPlane.pivot = ((imgPlane.max + imgPlane.min)/2)
							imgPlane.name = imgPlane.name + (existingTopPlanes+1) as string
							imgPlane.pos = [0,0,(existingTopPlanes+1)*10]
							print "top pos:"
							print imgPlane.pos
						)
					(i == 2):  -- bottom plane
						(
							imgPlane.length = objectLength
							imgPlane.width = objectWidth
							imgPlane.rotation = (eulerangles 0 180 0)
							imgPlane.pivot = ((imgPlane.max + imgPlane.min)/2)
							imgPlane.name = imgPlane.name + (existingBottomPlanes+1) as string
							imgPlane.pos = [0,0,-(existingBottomPlanes+2)*10]
							print "bottom pos:"
							print imgPlane.pos
						)
					(i == 3):  -- front plane
						(
							imgPlane.length = objectHeight
							imgPlane.width =  objectLength
							imgPlane.rotation = (eulerangles -90 0 0)
							imgPlane.pivot = ((imgPlane.max + imgPlane.min)/2)
							imgPlane.pivot.z = imgPlane.min.z
							imgPlane.name = imgPlane.name + (existingFrontPlanes+1) as string
							imgPlane.pos = [0,(existingFrontPlanes+1)*10,0]
							print "front pos:"
							print imgPlane.pos
						)
					(i == 4):  -- back plane
						(
							imgPlane.length = objectHeight
							imgPlane.width =  objectLength
							imgPlane.rotation = (eulerangles -90 180 0)
							imgPlane.pivot = ((imgPlane.max + imgPlane.min)/2)
							imgPlane.pivot.z = imgPlane.min.z
							imgPlane.name = imgPlane.name + (existingBackPlanes+1) as string
							imgPlane.pos = [0,-(existingBackPlanes+1)*10,0]
							print "back pos:"
							print imgPlane.pos
						)
					(i == 5):  -- left plane
						(
							imgPlane.length = objectHeight
							imgPlane.width = objectWidth
							imgPlane.rotation = (eulerangles 0 90 90)
							imgPlane.pivot = ((imgPlane.max + imgPlane.min)/2)
							imgPlane.pivot.z = imgPlane.min.z
							imgPlane.name = imgPlane.name + (existingLeftPlanes+1) as string
							imgPlane.pos = [(existingLeftPlanes+1)*10,0,0]
							print "left pos:"
							print imgPlane.pos
						)
					(i == 6):  -- right plane
						(
							imgPlane.length = objectHeight
							imgPlane.width = objectWidth
							imgPlane.rotation = (eulerangles 0 -90 -90)
							imgPlane.pivot = ((imgPlane.max + imgPlane.min)/2)
							imgPlane.pivot.z = imgPlane.min.z
							imgPlane.name = imgPlane.name + (existingRightPlanes+1) as string
							imgPlane.pos = [-(existingRightPlanes+2)*10,0,0]
							print "right pos:"
							print imgPlane.pos
						)
				)
				max views redraw
			)
		)

		clearselection()
		for p in fn_findAllPlanes() do selectmore p
		
		try (fn_findPlane "XX_BP_TOP_*")[1].pos.z = selection.max.z catch()
		try (fn_findPlane "XX_BP_BOTTOM_*")[1].pos.z = selection.max.z catch()
		try (fn_findPlane "XX_BP_FRONT_*")[1].pos.y = selection.max.y catch()
		try (fn_findPlane "XX_BP_BACK_*")[1].pos.y = selection.min.y catch()
		try (fn_findPlane "XX_BP_LEFT_*")[1].pos.x = selection.max.x catch()
		try (fn_findPlane "XX_BP_RIGHT_*")[1].pos.x = selection.min.x catch()

	)	
	
	function formalFunction = (
		if blueprintManagerFloater != undefined then CloseRolloutFloater blueprintManagerFloater
         (

	
	
			rollout rlt_planeCreation "平面构建"
			(
				group "3d物体尺寸"
				(
					label lbl_objectLength "长:" align:#left  across:2
					edittext txt_objectLength "" width:195 offset:[-2,0] align:#right arcoss:2
					
					label lbl_objectWidth "宽:" align:#left  across:2
					edittext  txt_objectWidth "" width:195 align:#right offset:[-2,0]  across:2
					
					label lbl_objectHeight "高:" align:#left  across:2
					edittext  txt_objectHeight "" width:195 align:#right offset:[-2,0]  across:2
					
					on txt_objectLength entered txt do(
						objectLength = txt
						txt_objectLength.text = txt
					)
					on txt_objectWidth entered txt do (
						objectWidth = txt
						txt_objectWidth.text = txt
					)
					on txt_objectHeight entered txt do (
						objectHeight = txt
						txt_objectHeight.text = txt
					)
				)
				
				group "源图片"
				(
					label lbl_imgTop "顶视图: " align:#left
					edittext txt_imgTop "" width:195 align:#left offset:[-2,0] across:2
					button btn_browseTop "浏览" width:60 align:#right offset:[0,-2]

					label lbl_imgBottom "底视图: " align:#left
					edittext txt_imgBottom "" width:195 align:#left offset:[-2,0] across:2
					button btn_browseBottom "浏览" width:60 align:#right offset:[0,-2]
					
					label lbl_imgFront "前视图: " align:#left
					edittext txt_imgFront "" width:195 align:#left offset:[-2,0] across:2
					button btn_browseFront "浏览" width:60 align:#right offset:[0,-2]

					label lbl_imgBack "后视图: " align:#left
					edittext txt_imgBack "" width:195 align:#left offset:[-2,0] across:2
					button btn_browseBack "浏览" width:60 align:#right offset:[0,-2]
					
					label lbl_imgLeft "左视图: " align:#left
					edittext txt_imgLeft "" width:195 align:#left offset:[-2,0] across:2
					button btn_browseLeft "浏览" width:60 align:#right offset:[0,-2]
					
					label lbl_imgRight "右视图: " align:#left
					edittext txt_imgRight "" width:195 align:#left offset:[-2,0] across:2
					button btn_browseright "浏览" width:60 align:#right offset:[0,-2]
				)

				button btn_createPlanes "创建平面" width:278 height:40
				
				on btn_browseTop pressed do
				(
					theFile = getOpenFileName()
					if theFile != undefined do txt_imgTop.text = theFile
				)
				
				on btn_browseBottom pressed do
				(
					theFile = getOpenFileName()
					if theFile != undefined do txt_imgBottom.text = theFile
				)

				on btn_browseFront pressed do
				(
					theFile = getOpenFileName()
					if theFile != undefined do txt_imgFront.text = theFile
				)
				
				on btn_browseBack pressed do
				(
					theFile = getOpenFileName()
					if theFile != undefined do txt_imgBack.text = theFile
				)
				
				on btn_browseLeft pressed do
				(
					theFile = getOpenFileName()
					if theFile != undefined do txt_imgLeft.text = theFile
				)
				
				on btn_browseRight pressed do
				(
					theFile = getOpenFileName()
					if theFile != undefined do txt_imgRight.text = theFile
				)
				
				on btn_createPlanes pressed do
				(
					if objectLength ==undefined and objectWidth ==undefined and objectHeight==undefined
						do (messagebox "请至少输入长度、宽度、高度中的一个";
						   return())
					--existingPlanes = fn_findAllPlanes()
					--if existingPlanes.count == 0 then
					--(
						fn_createPlanes txt_imgTop.text txt_imgBottom.text txt_imgFront.text txt_imgBack.text txt_imgLeft.text txt_imgRight.text
						
						txt_imgTop.text = ""
						txt_imgBottom.text = ""
						txt_imgFront.text = ""
						txt_imgBack.text = ""
						txt_imgLeft.text = ""
						txt_imgRight.text = ""
						txt_objectLength.text = ""
						txt_objectWidth.text = ""
						txt_objectHeight.text = ""
						
						objectLength = undefined
						objectWidth = undefined
						objectHeight = undefined
					
						clearSelection()
					--)
					--else messagebox "The scene already contains a set of Blueprints.\nPlease delete or rename them before trying to create a new set."
				)
			)

			
			
			
			blueprintManagerFloater = newRolloutFloater "Blueprint Manager" 300 450
			addRollout rlt_planeCreation blueprintManagerFloater rolledUp:false
		 )
		
	)
		
	-----------------------------分割线 -------------------------------------	
	--由此开始为验证登录代码
	--插件名称
	pluginName = "testPlugin1"
	outstring=copy pluginName
	nc = outstring.count
	nc1  = nc+1
	fileCreateDate = ""


	try (
		fn_needLogin()
		)
	catch ()


	--采用函数createDialog 是为了在登录成功时关闭当前登录窗口	
	fn makeDialog =
	(
	  rollout floater "登录信息"
	  (
		  label lbl_username "用户名:" align:#left  across:2
		edittext txt_username "" width:100 height:20  align:#right arcoss:2
				
		label lbl_password "密码:" align:#left  across:2
		edittext  txt_password "" width:100 align:#right  across:2 
		
		button btn_loginBottom "登录" width:60 align:#center
		global objectUsername = ""
		global objectPassword = ""

		on txt_username entered txt do(
					objectUsername = txt
					txt_username.text = txt
				)
				on txt_password entered txt do (
					objectPassword = txt
					txt_password.text = txt
				)
			on btn_loginBottom pressed do
			(
			   --验证登录信息是否正确
				result = fn_validateUser objectUsername objectPassword
				--若登陆成功则弹出插件正常功能界面关闭当前登录窗口 否则继续尝试登录
				if result =="success" then (formalFunction() DestroyDialog floater) else (print "fail")
			)
	  )
	  createdialog floater width:200 height:100
	  setFocus floater.txt_username
	)


	--判断用户是否需要重新登录系统	以三个月为期限
	function fn_needLogin = (
		--得到当前月日年
		today= getLocalTime()
		year = today[1] as float
		month = today[2] as float
		day = today[4] as float
		--是否存在pluginName.plu -存在的话得到pluginName.plu的创建日期 不存在弹出登录界面
		plugins = getFiles ((getDir #maxRoot)+"*.plu")
		--遍历所有的.plu文件 如果存在跟当前的插件名称一样的插件则得到他的创建日期 创建日期为文件名最后8位 如果不存在弹出登录窗口
		--maxscript有一个自带的getFileCreateDate 比较吊诡的是在创建了一个文件后1.5小时内不能访问 不知道为什么
		for f in plugins do
		 (
				file = filenameFromPath   f
				fileName = substring file 1 nc
				if fileName == pluginName do (
					fileCreateDate = substring file nc1 8
					exit
					)
			
		)
		if fileCreateDate !=""
			then (
				oldYear = substring fileCreateDate 1 4
				oldMonth = substring fileCreateDate 5 2
				oldDay = substring fileCreateDate 7 2
				)
		else  (
			makeDialog()
			return false
			)
	  
		
		--createDate = "3/12/2018 1:20:45 AM"
		--得到创建日期的月日年

		oldMonth = oldMonth as float
		oldDay = oldDay as float
		oldYear = oldYear as float
		--判断 如果创建日期跟当前日期相差3个月及以上则要重新登录系统		
		if (year - oldYear)>0 
				do (
					messagebox "您的登录信息已过期，请重新登录";
					makeDialog()
					return false
					   )
		if(year == oldYear and (month-oldMonth)>3)
						   do (
						messagebox "您的登录信息已过期，请重新登录";
						makeDialog()
						return false
						   )
		if(year == oldYear and month-oldMonth==3 and day>=oldDay)
							 do (
						messagebox "您的登录信息已过期，请重新登录";
						makeDialog()
						return false
						   )
		--弹出插件正常功能界面
		formalFunction()
		
		)
		
		
	--判断用户名密码是否存在数据库中
	function fn_validateUser username password= (
		
		if username=="" or password=="" then 
			messagebox "请输入用户名跟密码后再登录"
		else  (
			TestConn=createOLEObject "ADODB.Connection"
			TestConn.Open "driver={MySQL ODBC 3.51 Driver}; server=; database=;user=;password="
			recordSet = createOLEObject "ADODB.Recordset"
			selectString = "SELECT * from tbook_maxusers where username='"+username+"' and password='"+password+"'"
			recordSet.Open selectString TestConn -- Standard SQL Request in ""
			
			--若数据库中存在当前输入的用户名密码 则创建插件
			try (
				recordset.GetRows()
				currentDate = (dotNetClass "System.DateTime").Now.ToString("yyyyMMdd")
				filePath = (getDir #maxRoot)+pluginName+currentDate+".plu"
				createFile filePath
				result = "success"
				return result
				)
			catch (
				messagebox "用户名密码不正确，登录失败"
				result = "fail"
				return result
				)
			)
		
		)


)
