
;Do we need to highlight them ??

axlCmdRegister(
	"move_relative"
	'move_relative
	)

alignDirection = "v"
listObjects = nil
lengthStep = 0.1

procedure( move_relative( )
	
	if( axlOKToProceed() then
		form = axlFormCreate( (gensym) "move_relative.form" (list "outer") 'callbackForm t)
		axlFormSetField( form "textStep" 0.1)
		axlFormDisplay( form)
		
		axlMsgPut( (list "Select texts to align"))
		
		axlSetFindFilter(
			?enabled '("TEXT")
			?onButtons '("TEXT")
			)
		axlOpenFindFilter()
		
		state = 0
		
		while( state == 0
			axlSingleSelectPoint()
			if( axlGetSelSet() != nil then
				listObjects = cons(car(axlGetSelSet()), listObjects)
			else
				if(state != nil then
					axlMsgPut( "We found nothing on your last pick. state: %d" state)
				)
			)
		)
	else
		axlMsgPut("Last command not finished. ")
	)
	
)

(defun axlFillRightClickMenu (state)
(prog ()
	caseq( state
		(0 	popup0 = axlUIPopupDefine( nil
					(list 
						(list "Next" 'axlNext0)
						(list "Oops" 'axlOops0)
						(list "Cancel" 'axlCancel0)
					))
					axlUIPopupSet(popup0)
					)
		(1 	popup1 = axlUIPopupDefine( nil
					(list 
						(list "Oops" 'axlOops0)
						(list "Cancel" 'axlCancel0)
					))
		)
	)
)
)

(defun axlDone ()
	state = nil
	alignDirection = nil
	listObjects = nil
	axlFormClose(form)
	axlCancelEnterFun()
	axlClearSelSet()
	axlCloseFindFilter()
	axlShell( "done")
	axlMsgPut( "done! ")
)

(defun callbackForm (form)
	caseq( form->curField
		( "buttonMoveUp" 		axlMoveText( listObjects lengthStep 0))
		( "buttonMoveDown" 		axlMoveText( listObjects -lengthStep 0))
		( "buttonMoveLeft" 		axlMoveText( listObjects 0 -lengthStep))
		( "buttonMoveRight" 	axlMoveText( listObjects 0 lengthStep))
		( "textStep" 			lengthStep = atof(form->curValue))
		( "buttonDone" 			axlDone())
	)
)

(defun axlMoveText ( texts distanceUpDown distanceLeftRight )

	objects = nil
	i = 0
	foreach( text texts
		tempXy = text->xy
		tempText = text->text
		tempOrientation = make_axlTextOrientation( ?textBlock "1", ?rotation 0.0,
?mirrored nil, ?justify "CENTER")
		tempOrientation->textBlock = text->textBlock
		tempOrientation->rotation = text->rotation
		tempOrientation->mirrored = text->isMirrored
		tempOrientation->justify = text->justify
		tempParent = text->parent
		tempLayer = text->layer
		axlDeleteObject( text)
		tempDBID = axlDBCreateText( tempText (list nth( 0 tempXy)+distanceLeftRight nth( 1 tempXy)+distanceUpDown) tempOrientation tempLayer tempParent)
		objects = cons( caar(tempDBID) objects)
		i++
	)
	listObjects = objects
)