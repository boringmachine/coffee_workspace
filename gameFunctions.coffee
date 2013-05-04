class SVGObject
	constructor : (o)->
		@ele = $("##{o.id}")
		@params = o

class Boss extends SVGObject
	move_boss: (degree)->
		@params.degree += degree
		tempY = @params.y + Math.cos(@params.degree* Math.PI/45) * 100
		@ele.attr "transform", "translate(#{@params.x},#{tempY})"
		tempY

class Fighter extends SVGObject
	move_fighter: (conf)->
		pushUP = (@params.y > 2) and (conf.kc is conf.upcode)
		if pushUP then @params.y -= conf.speed

		pushDOWN = (@params.y < 280) and (conf.kc is conf.downcode)
		if pushDOWN then @params.y += conf.speed
		
		@ele.attr "transform", "translate(#{@params.x},#{@params.y})"

class Beam extends SVGObject
	shot_beam: (tempY,speed,boss)->

		if @params.flag is on then @params.x += speed
		if @params.x > @params.limitX then @params.flag = off

		@check1 tempY, boss
		@ele.attr "transform", "translate(#{@params.x},#{@params.y})"

	check1: (tempY,bossObj)->
		boss = bossObj.params
	
		xInRange = (@params.x-62) < boss.x < (@params.x+20)
		yInRange = (@params.y-86) < tempY  < (@params.y+ 2)
	
		if xInRange and yInRange 
			$("#hit").html boss.power
			if (boss.power is 0)
				alert("ミッション成功!!")
				boss.power = -1
				location.reload()
				return

			boss.power -= 1
			bossObj.ele.attr "fill", boss.colors[boss.power].color
			@params.flag = off
			@params.x = -100
			@ele.attr "transform", "translate(#{@params.x},#{@params.y})"
				

class Tama extends SVGObject
	shot_tama: (tempY,speed,boss,fighter)->
		
		if (@params.flag is on)
			@params.x -= speed
			@params.y += @params.dy * speed

			if (@params.x < 0) then @params.flag = off
			@check2 fighter.params

		else
			@params.dy = (fighter.params.y - (tempY+65)) / boss.params.x
			@params.y = tempY+65
			@params.x = boss.params.x
			@params.flag = true
		
		@params.degree += 10
		@ele.attr "transform", "translate (#{@params.x},#{@params.y}) rotate(#{@params.degree})"
 
	check2: (fighter)->
		xInRange = (@params.x-20) < fighter.x < (@params.x+20)
		yInRange = (@params.y-15) < fighter.y < (@params.y+ 9)

		if xInRange and yInRange
			alert("ゲームオーバー")
			fighter.x = -1
			fighter.y = -1
			location.reload()
			return

class GameRunner
	constructor: (obj)->
		@elements = 
			boss : new Boss(obj.boss)
			fighter : new Fighter(obj.fighter)
			tama : new Tama(obj.tama)
			beam : new Beam(obj.beam)
		
	initKeyEvent: (o)->
		es = @elements
		window.addEventListener "keydown", (evt)->
			evt.preventDefault()
			conf =
				kc:evt.keyCode
				speed:o.speed
				upcode:o.upcode
				downcode:o.downcode			 
			es.fighter.move_fighter conf
		,true
		
	initMouseEvent: ()->
		es = @elements
		window.addEventListener "click", (evt)->
			evt.preventDefault()
			beam = es.beam.params
			if beam.flag is on then return
			beam.flag = true
			beam.x = es.fighter.params.x + 20
			beam.y = es.fighter.params.y + 10
		, true

	setGameEvents: (o)->
		es = @elements
		$("##{o.id}").click (evt)->
			evt.preventDefault()
			setInterval =>
				tempY = es.boss.move_boss o.bossspeed
				es.tama.shot_tama tempY, o.tamaspeed, es.boss, es.fighter
				es.beam.shot_beam tempY, o.beamspeed, es.boss
			, o.interval


$.getJSON "data.json",(o)->
	runner = new GameRunner o
	fighter = runner.elements.fighter
	
	fighter.ele.attr "transform", "translate(#{fighter.params.x},#{fighter.params.y})"

	$.getJSON "setting.json",(o)->
			
		$btn = $("#" + o.basic.id).click ->
			$(@).hide()
		
		runner.setGameEvents(o.basic)
		runner.initKeyEvent(o.key)
		runner.initMouseEvent()
