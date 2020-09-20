#####################
# escape room game! #
#####################
import sys
import os
import time
import random

#creating player class and defining characteristics
class Player:
	def __innit__(self):
		self.name = ''
		self.hp = ''
		self.location = ''
		self.solved = ''

def print_speed(string, speed=0.05): #make the text come out letter by letter, at a certain speed
	for character in string:
		sys.stdout.write(character)
		sys.stdout.flush()
		time.sleep(speed)

##########################################################################################################################################################
### MAP ###
##########################################################################################################################################################
"""
the map is a 3x3 grid. PC starts in the centre 

  1	  2   3
-------------
| A | A	| A | a
-------------
| E	| x	| A	| b
-------------
| A	| A	| N	| c
-------------
"""
# this needs to be here to set the following variables
# otherwise the names in the dictionary would need to be strings and that's not as readable i guess?
zonename = "zonename"
description = "description"	# describes the room and includes prompt
description2 = 'description2' # leading to game_complete()
description3 = 'description3' # leading to game_complete()
examination = "examination"	# option 1 action: initiates riddle
examination2 = "examination2" # for volcano area after success
talk = "talk"	# option 2 action: initiates riddle. included for more PC_action options
answer = "answer"
success = "success" # upon correct answer
talkafter = "talkafter" # what is displayed upon examine or talk, after solved = True
north = "north"
south = "south"
east = "east"
west = "west"
solved = False

solved_places = {'a1': False, 'a2': False, 'a3': False,
				'b1': False, 'b2': False, 'b3': False,
				'c1': False, 'c2': False, 'c3': False}

puzzle_talk = ['a1','a2','a3','b3','c1','c2','c3']
puzzle_examine = ['b1']
game_room = ['a2','b1','b3','c2']
final_room = ['b2']
hint_room = ['a1','a3','c1','c3']

zonemap = {
	'a1':{zonename:"Telephone Shop [Hint Room]", # required for b1
		description: "You enter a quaint little telephone shop.\n\nA man sits behind the counter, polishing some small parts. He notices you as you walk in and shoots you a welcoming smile.\n\nThere are doors to the south and east.",
		examination: "The shop seems quite well stocked. \nAll sorts of telephones - rotary phones, payphones, handphones - occupy every visible space in the small area.",
		talk: 'The man beckons you over.\n"Good day!. Here is a riddle for you: You answer me but I never ask any questions. What am I?"',
		answer: ["telephone", "phone"],
		success: '"Very good! Here, have an [UMBRELLA]. You might need it!"\n(You got a hint! type "hints" to see what you learned.)',
		talkafter: '"I don\'t have anything for you."',
		north: "a1",
		south: "b1",
		east: "a2",
		west: "a1",
		solved: False
	},
	'a2':{zonename:"Empty Country Road",
		description: "A country road.\nA tree.\nThose are the only defining features of the space that you find yourself in.\n\nTwo men in bowler hats stand beneath the tree, seemingly in an intense discussion.\n\nThere are doors to the south, east and west.",
		examination: "The landscape is eerily empty. \nA broken belt drapes over one of the tree branches, and you see a pair of discarded boots nearby.",
		talk: 'As you approach them, you hear the taller man say,\n"Estragon, we can\'t just leave! We\'re waiting for..."\n\nHe turns to you and asks, \n"..Who are we waiting for again?"',
		answer: "godot",
		success: '"Oh yes, Godot. We\'ve been waiting for him forever!"',
		talkafter: 'The shorter of the pair laments, "Nothing happens. Nobody comes, nobody goes. It\'s awful."\nThere\'s nothing more to do here.',
		north: "a2",
		south: "b2",
		east: "a3",
		west: "a1",
		solved: False
	},
	'a3':{zonename:"Studio [Hint Room]", # hint for a2
		description: "Every inch of the little room is crammed with paper and tomes.\nAmidst this sea of literature, you barely notice a diminutive, frazzled-looking man on the far side of the room.\n\nThe man is hunched over a table, and looks up as you close the door.\n\nThere are doors to the south and west.",
		examination: "You grab a book off a pile; one of many stacked precariously on top of each other.\nYou notice that it, similar to many other manuscripts you find, discusses a recurrent topic: the history of famous plays and playwrights.\nPerhaps you are in a historian's abode.",
		talk: 'The man flashes you a tired smile and says, \n"Hey there. Could you help me recall the name of this fellow? A French playwright whose most famous work involves waiting for someone. Samuel...?',
		answer: "beckett",
		success: '"Of course! He wrote Waiting For Godot - how could I forget!"\n(You got a hint! type "hints" to see what you learned.)',
		talkafter: '"Leave me now. I must focus on the task at hand."',
		north: "a3",
		south: "b3",
		east: "a3",
		west: "a2",
		solved: False
	},
	'b1':{zonename:"Volcanic Crater",
		description: "You're standing on the edge of a volcanic crater. \nLava spurts from gashes in the rock, and the blistering heat is almost unbearable.\n\nThere's a bright pink lever in the centre.\n\nThere are doors to the north, south and east.",
		examination: "Whoa! You narrowly dodge a spout of lava. \nYou don't have an [UMBRELLA] to protect yourself, better look elsewhere first!",
		examination2: "The volcano looks fit to erupt. Better get out fast!",
		talk: "There's nobody here to talk to.",
		answer: "",
		success: "You use the [UMBRELLA] to shield yourself from the lava spouts. \nYou reach the centre of the crater and successfully pull the lever. DING!",
		talkafter: "",
		north: "a1",
		south: "c1",
		east: "b2",
		west: "b1",
		solved: False
	},
	'b2':{zonename:"A Plain Room", # starting area
		description: "It is a rather plain room. \nYou see a closed, wooden door on each of the four walls.\nA manhole cover lies in the middle of the room, secured by a hefty padlock.",
		description2: 'It is a rather plain room. \nYou see a closed, wooden door on each of the four walls.\nA manhole cover lies in the middle of the room, secured by a hefty padlock.\n\nThe manhole cover seems battered, as if someone had been slamming into it with great force.',
		description3: "It is a rather plain room. \nYou see a closed, wooden door on each of the four walls.\n\nA charred smell fills the air. \nYou notice the manhole cover has been blown to pieces across the room.\nA dark hole lies in its place, a rickety ladder extending from the top to a bottom you can't see.",
		examination: "Near the northern door, you notice a few leaves on the ground. \nAt the southern door, the smells of incense and fragant oils fill your nose. \nAt the eastern door, you hear thunder and notice water seeping through the bottom of the door. \nFrom the western door radiates an intense heat. You almost burn yourself when you touch it.\n\nThe manhole appears unusually normal amidst all this, but you can't seem to approach it.",
		examination2: "Near the northern door, you notice a few leaves on the ground. \nAt the southern door, the smells of incense and fragant oils fill your nose. \nAt the eastern door, you hear thunder and notice water seeping through the bottom of the door. \nFrom the western door radiates an intense heat. You almost burn yourself when you touch it.\n\nThe manhole has been blown wide open by an unseen force.",
		talk: "There's nobody here to talk to.",
		answer: "",
		success: "",
		talkafter: "",
		north: "a2",
		south: "c2",
		east: "b3",
		west: "b1",
		solved: False
	},
	'b3':{zonename: "Cruise Ship",
		description: "All around you, gargantuan waves slam onto the deck.\nAn incessant deluge is punctuated by white streaks of lightning and booming thunder.\nThe ship suddenly lurches - you realise it's sinking! \nIt's utter chaos.\n\nA disheveled man is running at you, screaming.\n\nThere are doors to the north, south and west.",
		examination: "You carefully peer over the side of the ship and notice a giant ICEBERG lodged in the hull.\nWater is seeping in fast; you'd better do what you came here for and leave quickly!",
		talk: 'The man frantically exclaims,\n"Am I in a shitty movie or something!? I have to find Rose!!"\n\nWhat is the name of this movie?',
		answer: "titanic",
		success: '"I knew I shouldn\'t have come on this damn ship!!"',
		talkafter: "The ship is still sinking, but there's nothing more you can do here.",
		north: "a3",
		south: "c3",
		east: "b3",
		west: "b2",
		solved: False
	},
	'c1':{zonename:"Movie Theatre [Hint Room]", # hint for b3
		description: "You step into a crowded movie theatre. \nRather tired from your adventure, you find a cushy seat and enjoy the show.\n\nThe guy next to you irritatingly tries to get your attention.\n\nThere are doors to the north and east.",
		examination: "The movie's pretty good! It's about blue people who have sex using their hair. \nYou think this is pretty weird, but what the heck.",
		talk: '"Psst! What\'s the last name of the director of this movie? Steven...something?"',
		answer: "spielberg",
		success: '"Thanks man! Did you know he directed Titanic too?"\n(You got a hint! type "hints" to see what you learned.)',
		talkafter: "You tell him to shut up and watch the movie.",
		north: "b1",
		south: "c1",
		east: "c2",
		west: "c1",
		solved: False
	},
	'c2':{zonename:"Royal Tomb", # EDIT THE DESCRIPTION
		description: "This room is richly decorated, containing a myriad of glittering treasures.\n\nA dilapidated sarcophagus stands alone in the centre of the room, its door slightly ajar.\nA faint voice emnates from it.\n\nThere are doors to the north, east and west.",
		examination: "The large room reeks of extravagance. \nEvery surface is lined with glittering crystals and precious stones, and large, intricate tapestries adorn the walls.",
		talk: 'From the sarcophagus, a voice whispers, \n"What has six faces, but does not wear makeup, has twenty-one eyes, but cannot see?"',
		answer: ["die", "dice"],
		success: '"Well done... traveller...!"',
		talkafter: "The sense of dread grows the longer you stay. You think it might be better to leave.",
		north: "b2",
		south: "c2",
		east: "c3",
		west: "c1",
		solved: False
	},
	'c3':{zonename:"Desert [Hint Room]", # hint for c2; no puzzle here
		description: "Your throat immediately grows parched and your skin feels as if pricked by a thousand needles as a vast landscape of barren sand is unveiled. \nSuddenly, you are covered in shadow. \n\nLooking up, you gaze at an enormous chimera of rock and gravel. Its body is a lion and huge wings sprout from its back. \nFrom atop this terrifying body, a woman's face glares down at you.\n\nThere are doors to the north and west.",
		examination: 'The harsh sunlight and torrid heat assault your senses.\nThe air itself blurs and shimmers.\nTumbleweeds roll across the barren dunes - there is no life here.',
		talk: 'The sphinx growls, \n"What walks on 4 legs in the morning, 2 legs at noon, and 3 legs in the evening?"',
		answer: ['human', 'man'],
		success: '"You rolled the dice and came out lucky this time, mortal. Leave!"\n(You got a hint! type "hints" to see what you learned.)',
		talkafter: '"Be gone, insufferable mortal!"',
		north: "b3",
		south: "c3",
		east: "c3",
		west: "c2",
		solved: False
	},
}

def map():
	if Player.location == 'a1':
		print('                               ')
		print('  ______________N______________')
		print(' |         |         |         |')
		print(' |   You   |         |         |')
		print(' |_________|_________|_________|')
		print(' |         |         |         |')
		print('W|         |    x    |         |E')
		print(' |_________|_________|_________|')
		print(' |         |         |         |')
		print(' |         |         |         |')
		print(' |_________|_________|_________|')
		print('                S               \n')
	elif Player.location == 'a2':
		print('                               ')
		print('  ______________N______________')
		print(' |         |         |         |')
		print(' |         |   You   |         |')
		print(' |_________|_________|_________|')
		print(' |         |         |         |')
		print('W|         |    x    |         |E')
		print(' |_________|_________|_________|')
		print(' |         |         |         |')
		print(' |         |         |         |')
		print(' |_________|_________|_________|')
		print('                S               \n')
	elif Player.location == 'a3':
		print('                               ')
		print('  ______________N______________')
		print(' |         |         |         |')
		print(' |         |         |   You   |')
		print(' |_________|_________|_________|')
		print(' |         |         |         |')
		print('W|         |    x    |         |E')
		print(' |_________|_________|_________|')
		print(' |         |         |         |')
		print(' |         |         |         |')
		print(' |_________|_________|_________|')
		print('                S               \n')
	elif Player.location == 'b1':
		print('                               ')
		print('  ______________N______________')
		print(' |         |         |         |')
		print(' |         |         |         |')
		print(' |_________|_________|_________|')
		print(' |         |         |         |')
		print('W|   You   |    x    |         |E')
		print(' |_________|_________|_________|')
		print(' |         |         |         |')
		print(' |         |         |         |')
		print(' |_________|_________|_________|')
		print('                S               \n')
	elif Player.location == 'b2':
		print('                               ')
		print('  ______________N______________')
		print(' |         |         |         |')
		print(' |         |         |         |')
		print(' |_________|_________|_________|')
		print(' |         |         |         |')
		print('W|         |   You   |         |E')
		print(' |_________|_________|_________|')
		print(' |         |         |         |')
		print(' |         |         |         |')
		print(' |_________|_________|_________|')
		print('                S               \n')
	elif Player.location == 'b3':
		print('                               ')
		print('  ______________N______________')
		print(' |         |         |         |')
		print(' |         |         |         |')
		print(' |_________|_________|_________|')
		print(' |         |         |         |')
		print('W|         |    x    |   You   |E')
		print(' |_________|_________|_________|')
		print(' |         |         |         |')
		print(' |         |         |         |')
		print(' |_________|_________|_________|')
		print('                S               \n')
	elif Player.location == 'c1':
		print('                               ')
		print('  ______________N______________')
		print(' |         |         |         |')
		print(' |         |         |         |')
		print(' |_________|_________|_________|')
		print(' |         |         |         |')
		print('W|         |    x    |         |E')
		print(' |_________|_________|_________|')
		print(' |         |         |         |')
		print(' |   You   |         |         |')
		print(' |_________|_________|_________|')
		print('                S               \n')
	elif Player.location == 'c2':
		print('                               ')
		print('  ______________N______________')
		print(' |         |         |         |')
		print(' |         |         |         |')
		print(' |_________|_________|_________|')
		print(' |         |         |         |')
		print('W|         |    x    |         |E')
		print(' |_________|_________|_________|')
		print(' |         |         |         |')
		print(' |         |   You   |         |')
		print(' |_________|_________|_________|')
		print('                S               \n')
	elif Player.location == 'c3':
		print('                               ')
		print('  ______________N______________')
		print(' |         |         |         |')
		print(' |         |         |         |')
		print(' |_________|_________|_________|')
		print(' |         |         |         |')
		print('W|         |    x    |         |E')
		print(' |_________|_________|_________|')
		print(' |         |         |         |')
		print(' |         |         |   You   |')
		print(' |_________|_________|_________|')
		print('                S               \n')

##########################################################################################################################################################
### TITLE SCREEN ###
##########################################################################################################################################################
def start_screen():
	os.system('clear')
	print("########################")
	print("# Welcome to the Maze! #")
	print("########################")
	print("        - Play -        ")
	print("        - Help -        ")
	print("        - Quit -        ")
	selection = input(">>> ")
	if selection.lower() == "play":
		game_start()
	elif selection.lower() == "help":
		help_screen()
	elif selection.lower() == "quit":
		sys.exit()
	else:
		os.system('clear')
		start_screen()

def help_screen():
	print("#############################################################################")
	print("#                              - help screen -                              #")
	print("#         type 'move' followed by a direction to change locations.          #")
	print("#           type 'examine' or 'talk' to interact with the world.            #")
	print("#            type 'hints' to check your currently learned hints.            #")
	print("#             use 'progress' to check on your current progress.             #")
	print("#                    type 'help' to display this guide.                     #")
	print("#                                                                           #")
	print("#        Your goal is to solve all 4 puzzles, in the NSEW directions.       #")
	print("#    If you're having trouble, there are hint rooms in the corner rooms!    #")
	print("#############################################################################\n")
	selection = input(">>> ")
	if selection.lower() == "back":
		start_screen()
	elif selection.lower() == 'play':
		game_start()
	else:
		help_screen()

##########################################################################################################################################################
### GAME START & END ###
##########################################################################################################################################################
def help_screen_game():
	print("#############################################################################")
	print("#                              - help screen -                              #")
	print("#         type 'move' followed by a direction to change locations.          #")
	print("#           type 'examine' or 'talk' to interact with the world.            #")
	print("#            type 'hints' to check your currently learned hints.            #")
	print("#             use 'progress' to check on your current progress.             #")
	print("#                    type 'help' to display this guide.                     #")
	print("#                                                                           #")
	print("#        Your goal is to solve all 4 puzzles, in the NSEW directions.       #")
	print("#    If you're having trouble, there are hint rooms in the corner rooms!    #")
	print("#############################################################################\n")
	prompt()

def game_start():
	os.system('clear')
	preface1 = '                       Tips:\n'
	preface2 = 'Be sure to read the information in each room carefully!\n'
	preface3 = '     If you\'re stuck, type "help" or "progress"!\n'  
	print(preface1)
	print_speed(preface2, 0.03)
	print_speed(preface3, 0.03)
	time.sleep(3)
	os.system('clear')
	intro = "Hi there, what is your name?\n"
	print_speed(intro)
	pcname = input(">>> ")
	while pcname == "":
		pcname = input(">>> ")
	# initial PC attributes #
	Player.name = pcname.capitalize()
	Player.hp = 100
	Player.location = 'b2'
	Player.solved = 0
	# initial PC attributes #
	intro2 = "Welcome, " + Player.name + "! How are you feeling?\n"
	print_speed(intro2)
	my_feeling = input(">>> ")
	if my_feeling.lower() in good_feels:
		reply = "That's wonderful, " + Player.name + ".\n"
		print_speed(reply)
	elif my_feeling.lower() in meh_feels:
		reply = "It\'s alright. Some days are just like that, you know?\n"
		print_speed(reply)
	elif my_feeling.lower() in bad_feels:
		reply = "I\'m sorry you feel that way, " + Player.name + ".\n"
		print_speed(reply)
	else:
		reply = "I don't know how to reply to that.\n"
		print_speed(reply)
	time.sleep(1)
	intro3 = "\nPop quiz time!\n"
	print_speed(intro3)
	time.sleep(0.5)
	pop_quiz()

good_feels = ['good','great','wonderful','amazing','content','pleased','happy','awesome','thrilled','overjoyed','excited','fantastic','glad']
meh_feels = ['meh','ok','okay','k','idk','dunno','melancholic','anything','unsure','...','confused','tired','sian','exhausted']
bad_feels = ['sad','bad','lousy','better','shit','like shit','awful','terrible','unwell','poor','sick','horrible']

def pop_quiz():
	question = random.randint(1,3)
	if question == 1:
		qn = "How many slices of bread can a single bolt of lightning toast?\n"
		print_speed(qn)
		answer = input(">>> ")
		if answer.lower() != "100":
			reply = "\n...Nice try.\n"
			print_speed(reply)
			game_startstart()
		else:
			reply = "\nYou're smarter than I thought.\n"
			print_speed(reply)
			game_startstart()
	elif question == 2:
		qn = "Where is the largest pyramid in the world located?\n"
		print_speed(qn)
		answer = input(">>> ")
		if answer.lower() != "mexico":
			reply = "\n...Nice try.\n"
			print_speed(reply)
			game_startstart()
		else:
			reply = "\nYou're smarter than I thought.\n"
			print_speed(reply)
			game_startstart()
	elif question == 3:
		qn = "How much wood could a woodchuck chuck if a woodchuck could chuck wood? (numerical, in pounds)\n"
		print_speed(qn)
		answer = input(">>> ")
		if answer.lower() != "700":
			reply = "\n...Nice try.\n"
			print_speed(reply)
			game_startstart()
		else:
			reply = "\nYou're smarter than I thought.\n"
			print_speed(reply)
			game_startstart()

def game_startstart():
	intro4 = "Well, it's time for us to part.\nHave fun exploring! Hope you survive...\n"
	intro5 = "Hehehe..."
	time.sleep(1)
	print_speed(intro4)
	print_speed(intro5, 0.2)
	time.sleep(2)
	
	os.system('clear')
	print("##############################")
	print("# Your adventure starts here #")
	print("##############################")
	print()
	intro6 = "You get up from the floor, groggy as hell. What was that all about?\nLooking around, you see a crinkled [NOTE] on the ground.\n"
	print(intro6)
	print("(type 'examine' and press enter)")
	firstmove = input('>>>')
	while firstmove.lower() != 'examine':
		firstmove = input('>>>')
	intro7 = "\nYou pick up the [NOTE]. On one side, there is a [MAP]. On the other, it reads:\n"
	intro8 = "\nHey there, " + Player.name + ".\nLooks like you're stuck in here too.\n"
	intro9 = "\nFrom what I've discovered, there are 4 riddles you need to solve. \nThey're in the NORTHERN, SOUTHERN, EASTERN and WESTERN rooms.\n"
	#intro10 = "After solving each riddle, something seems to occur in the [Plain Room]. Don't know what, though.\n"
	intro11 = "\nIf you get stuck, I found some hints in the CORNER areas. They might be helpful.\n"
	intro12 = "A final note - the riddles are mostly themed to the room they're in.\nExcept the volcanic region; there wasn't any gatekeeper there, just a bright pink lever.\n"
	intro13 = "\nIt's too late for me, but I hope you can still find your way out.\n"
	intro14 = "Goodbye, " + Player.name + ".\n"
	print_speed(intro7)
	time.sleep(1)
	print_speed(intro8, 0.03)
	time.sleep(0.5)
	print_speed(intro9, 0.03)
	time.sleep(0.5)
	#print_speed(intro10, 0.03)
	print_speed(intro11, 0.03)
	time.sleep(0.5)
	print_speed(intro12, 0.03)
	time.sleep(0.5)
	print_speed(intro13)
	time.sleep(1)
	print_speed(intro14)
	time.sleep(1)
	print("\n(type 'ok' and press enter)")
	secondmove = input('>>>')
	while secondmove.lower() != 'ok':
		secondmove = input('>>>')

	os.system('clear')
	location_intro()
	print("#############################################################################")
	print("#                              - help screen -                              #")
	print("#         type 'move' followed by a direction to change locations.          #")
	print("#           type 'examine' or 'talk' to interact with the world.            #")
	print("#            type 'hints' to check your currently learned hints.            #")
	print("#             use 'progress' to check on your current progress.             #")
	print("#                 type 'help' to display this guide again.                  #")
	print("#                                                                           #")
	print("#        Your goal is to solve all 4 puzzles, in the NSEW directions.       #")
	print("#    If you're having trouble, there are hint rooms in the corner rooms!    #")
	print("#############################################################################\n")
	prompt()

def location_intro():
	print("##" + "#"*len(zonemap[Player.location][zonename]) + "##")
	print("# " + zonemap[Player.location][zonename] + " #")
	print("##" + "#"*len(zonemap[Player.location][zonename]) + "##")
	map()
	if Player.location == 'b2' and Player.solved >= 4:
		print(zonemap[Player.location][description3])
		print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
		game_complete()
	if Player.location == 'b2' and Player.solved >= 2:
		print(zonemap[Player.location][description2])
		print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	else:
		print(zonemap[Player.location][description])
		print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~")


def midgame(): #just a short cutscene that transports the player back to the Plain Room
	os.system('clear')
	mid1 = 'The ground lurches and begins to quake.\n'
	mid2 = 'A gash opens in the earth, and you fall into darkness.\n\n'
	mid3 = 'YOU...\n'
	mid4 = 'I LET YOU ROAM FREELY, AND THIS IS WHAT YOU DO.\n'
	mid5 = 'DO NOT CONTINUE ANY FURTHER, OR EL-\n\n'
	mid6 =  Player.name + '!\n'
	mid7 = 'I\'ll hold him off. Quickly, solve the last 2 puzzles and escape!\n\n'
	mid8 = 'A sudden wave of force hits you, and your consciousness fades.\n'
	mid9 = '...\n'
	mid10 = '...\n\n'
	mid11 = 'You wake up in the [Plain Room].\n'
	mid12 = 'Something has changed.\n'
	print_speed(mid1)
	print_speed(mid2)
	time.sleep(1)
	print_speed(mid3, 0.1)
	time.sleep(1)
	print_speed(mid4)
	time.sleep(1)
	print_speed(mid5)
	time.sleep(0.5)
	print_speed(mid6, 0.03)
	print_speed(mid7, 0.03)
	time.sleep(1)
	print_speed(mid8)
	print()
	print_speed(mid9, 0.3)
	print_speed(mid10, 0.3)
	time.sleep(2)
	print_speed(mid11)
	print_speed(mid12)
	print("\n(type 'ok' and press enter)")
	midmove = input('>>>')
	while midmove != 'ok':
		midmove = input('>>>')
	Player.location = 'b2'
	os.system('clear')
	location_intro()
	prompt()

def game_complete():
	print("Do you wish to climb down the ladder? (Y/N)")
	answer = input(">>> ")
	if answer.lower() in ['n', 'no']:
		print()
		prompt()
	elif answer.lower() in ['y', 'yes']:
		os.system('clear')
		ending1 = "Apprehensively, you start climbing down the hole.\n"
		ending2 = "\nYou climb...\n"
		ending3 = "\nand climb...\n"
		ending4 = '\nEventually, you reach the bottom. A light shines in the distance. \nThat must be the way out!\n'
		ending5 = '\nSuddenly, a series of thunderous crashes from above.\n'
		ending6 = 'Something\'s coming. Something really bad.\n'

		ending7 = '\nWhat are you doing, ' + Player.name + '?!\n'
		ending8 = 'Run!!\n'
		#endmove1 here
		
		ending9 = 'You spin on your heels and dash towards the light.\n'
		ending10 = 'Behind you, the voices of your mysterious benefactor and your pursuer blend together into a cacophony of noise.\n'

		ending11 = '\nYou near the light.\n'

		ending12 = '\nAs you burst through the doorway, a deafening shriek explodes from behind!\n'
		ending13 = '...Then everything is quiet.\n'

		ending14 = '\nSlowly, you get up from the ground and survey your surroundings.\n'
		ending15 = 'No mysterious doors, no strange riddles.\n\n'

		ending16 = 'You\'re free.\n\n'
		print_speed(ending1)
		print_speed(ending2, 0.1)
		print_speed(ending3, 0.15)
		time.sleep(1)
		print_speed(ending4)
		time.sleep(1.2)
		print_speed(ending5, 0.03)
		time.sleep(0.5)
		print_speed(ending6, 0.03)
		time.sleep(0.5)
		print_speed(ending7, 0.03)
		time.sleep(1)
		print_speed(ending8, 0.03)
		endmove1 = input('>>>')
		print()
		print_speed(ending9, 0.04)
		print_speed(ending10, 0.04)
		time.sleep(0.5)
		print_speed(ending11, 0.04)
		time.sleep(0.5)
		print_speed(ending12, 0.04)
		print_speed(ending13, 0.07)
		time.sleep(1)
		print_speed(ending14)
		time.sleep(1)
		print_speed(ending15)
		time.sleep(1)
		print_speed(ending16)
		time.sleep(2)
		print("#####################")
		print("###### The End ######")
		print("#####################")
		print("\nPlay Again? (Y/N)")
		replay = input(">>> ")
		while replay.lower() not in ['y', 'yes', 'n', 'no']:
			replay = input(">>> ")
		if replay.lower() in ['y', 'yes']:
			start_screen()
		elif replay.lower() in ['n', 'no']:
			sys.exit()
			
	else:
		game_complete()

##########################################################################################################################################################
### Player Actions ###
##########################################################################################################################################################
def prompt(): # main screen that PC will take action from
	print("What would you like to do?")
	action = input(">>> ")
	action = action.strip()
	print()
	PC_actions = ['walk','move','go','run',
				'examine','inspect','look','search','explore',
				'ask','talk','question','chat',
				'pull','climb',
				'hints','progress','help','quit']
	if len(action.split()) > 1:
		while action.lower().split()[0] not in PC_actions:
			print("Unknown action, please try again.\n")
			prompt()
		if action.lower().split()[0] in ['walk','move','go','run']:
			PC_movementlong(action.lower().split()[0], action.lower().split()[1])
		elif action.lower().split()[0] in ['walk','move','go','run']:
			PC_movement(action.lower())
	else:
		while action.lower() not in PC_actions:
			print("Unknown action, please try again.\n")
			prompt()
		if action.lower() in ['walk','move','go','run']:
			PC_movement(action.lower())
		elif action.lower() in ['examine','inspect','look','search','explore']:
			PC_examine(action.lower())
		elif action.lower() in ['ask','talk','question','chat']:
			PC_talk(action.lower())
		elif action.lower() == 'pull':
			if Player.location == 'b1':
				PC_examine(action.lower())
			else:
				print("You can't do that here.\n")
				prompt()
		elif action.lower() == 'climb':
			if Player.location == 'b2' and Player.solved >= 4:
				game_complete()
			else:
				print("You can't do that here.\n")
				prompt()
		elif action.lower() == 'hints':
			hints()
		elif action.lower() == 'progress':
			progress()
		elif action.lower() == 'help':
			help_screen_game()
		elif action.lower() == 'quit':
			sys.exit()

def PC_movement(action):
	movement_directions = ['north', 'up', 'forward',
						'south', 'down', 'backward', 'back',
						'east', 'right', 
						'west', 'left',
						'cancel']
	print("Where would you like to go?")
	direction = input(">>> ")
	while direction not in movement_directions:
		print("That is not a valid direction. Please try again.")
		direction = input(">>> ")
	if direction.lower() == 'cancel':
		prompt()
	elif direction.lower() in ['north', 'up', 'forward']:
		dest = zonemap[Player.location][north]
		movement_shortcut(dest,'north')
	elif direction.lower() in ['south', 'down', 'backward', 'back']:
		dest = zonemap[Player.location][south]
		movement_shortcut(dest, 'south')
	elif direction.lower() in ['east', 'right']:
		dest = zonemap[Player.location][east]
		movement_shortcut(dest, 'east')
	elif direction.lower() in ['west', 'left']:
		dest = zonemap[Player.location][west]
		movement_shortcut(dest, 'west')

def PC_movementlong(action, direction):
	movement_directions = ['north', 'up', 'forward',
						'south', 'down', 'backward', 'back',
						'east', 'right', 
						'west', 'left',
						'cancel']
	while direction not in movement_directions:
		print("That is not a valid direction. Please try again.")
		direction = input(">>> ")
	if len(direction.split()) > 1:
		if direction.lower().split()[1] in ['north', 'up', 'forward']:
			dest = zonemap[Player.location][north]
			movement_shortcut(dest,'north')
		elif direction.lower().split()[1] in ['south', 'down', 'backward', 'back']:
			dest = zonemap[Player.location][south]
			movement_shortcut(dest, 'south')
		elif direction.lower().split()[1] in ['east', 'right']:
			dest = zonemap[Player.location][east]
			movement_shortcut(dest, 'east')
		elif direction.lower().split()[1] in ['west', 'left']:
			dest = zonemap[Player.location][west]
			movement_shortcut(dest, 'west')
	else:
		if direction.lower() == 'move':
			PC_movement()
		elif direction.lower() in ['north', 'up', 'forward']:
			dest = zonemap[Player.location][north]
			movement_shortcut(dest,'north')
		elif direction.lower() in ['south', 'down', 'backward', 'back']:
			dest = zonemap[Player.location][south]
			movement_shortcut(dest, 'south')
		elif direction.lower() in ['east', 'right']:
			dest = zonemap[Player.location][east]
			movement_shortcut(dest, 'east')
		elif direction.lower() in ['west', 'left']:
			dest = zonemap[Player.location][west]
			movement_shortcut(dest, 'west')

def movement_shortcut(destination, direction):
	os.system('clear')
	if Player.location == destination:
		#print("You reached a corner of the map. Try moving in a different direction!")
		location_intro()
		prompt()
	else:
		Player.location = destination
		#print("You have moved " + direction + " to the " + zonemap[Player.location][zonename] + ".")
		location_intro()
		prompt()

def PC_examine(action):
	if solved_places[Player.location] == False:
		if Player.location == 'b1':	# lava area just needs umbrella, no puzzle
			if solved_places['a1'] == True: # if i have [UMBRELLA], then i can solve the lava room.
				correct_answer()
			else:
				print(zonemap[Player.location][examination]) # if not, then normal examine and move on.
				print()
				prompt()
		elif Player.location == 'b2' and Player.solved >= 4:
			print(zonemap[Player.location][examination2])
			print()
			prompt()
		else:
			print(zonemap[Player.location][examination])
			print()
			prompt()
	else:
		 #only for lava area
		if Player.location == 'b1' and solved_places['b1'] == True:
			print(zonemap[Player.location][examination2])
			print()
			prompt()
		#all other areas
		else:
			print(zonemap[Player.location][examination])
			print()
			prompt()

def PC_talk(action):
	wrong_counter = 0
	if solved_places[Player.location] == False:
		print(zonemap[Player.location][talk])
		if Player.location in puzzle_talk:
			reply = input(">>> ")
			if reply == 'cancel':
				prompt()
			while reply.lower() not in zonemap[Player.location][answer]: # puzzle mechanics
				wrong_counter += 1
				print("Try again later, or explore a hint room for a clue!\n")
				prompt()
				# if wrong_counter < 2:
				# 	print("That's not the right answer! Try again.")
				# 	reply = input(">>> ")
				# else:
				# 	print("Try again later, or explore a hint room for a clue!\n")
				# 	prompt()
			if reply.lower() in zonemap[Player.location][answer]:
				print()
				correct_answer()
		else:
			print()
			prompt()
	else:
		if Player.location in puzzle_talk:
			print(zonemap[Player.location][talkafter])
			print()
			prompt()
		else:
			print(zonemap[Player.location][talk])
			print()
			prompt()

def correct_answer():
	print(zonemap[Player.location][success])
	solved_places[Player.location] = True
	if Player.location in game_room:
		Player.solved += 1
		print("\nPuzzles solved: " + str(Player.solved) + "/4")
		if Player.solved == 1:
			print('(You solved a puzzle! Type "progress" to see how many puzzles remain.)')
			print()
			print("You hear a rumbling noise somewhere in the far distance, behind one of the doors. Something has changed, but what?\n")
			prompt()
		elif Player.solved > 1 and Player.solved < 4:
			print("You hear a rumbling noise somewhere in the far distance, behind one of the doors. Something has changed, but what?\n")
			if Player.solved == 2:
				time.sleep(1)
				midgame()
			else:
				prompt()
		elif Player.solved == 4:
			print("You hear a loud CRASH coming from the [Plain Room]. Hurry back now!!\n")
			prompt()
		
	else:
		print()
		prompt()

def progress():
	print("Puzzles solved: " + str(Player.solved) + "/4")
	if solved_places['a2'] == True and solved_places['b1'] == True and solved_places['b3'] == True and solved_places['c2'] == True:
		print("Go to the [Plain Room] now!")
		print()
	if solved_places['a2'] == False and solved_places['b1'] == False and solved_places['b3'] == False and solved_places['c2'] == False:
		print("You haven't solved any puzzles.\n")
		prompt()
	elif solved_places['a2'] == True:
		print('You have solved the NORTHERN puzzle.')
		if solved_places['b1'] == True:
			print('You have solved the WESTERN puzzle.')
			if solved_places['b3'] == True:
				print('You have solved the EASTERN puzzle.')
				if solved_places['c2'] == True:
					print('You have solved the SOUTHERN puzzle.' )
					print()
					prompt()
				print()
				prompt()
			elif solved_places['c2'] == True:
				print('You have solved the SOUTHERN puzzle.' )
				print()
				prompt()
			print()
			prompt()
		elif solved_places['b3'] == True:
			print('You have solved the EASTERN puzzle.')
			if solved_places['c2'] == True:
				print('You have solved the SOUTHERN puzzle.' )
				print()
				prompt()
			print()
			prompt()
		elif solved_places['c2'] == True:
			print('You have solved the SOUTHERN puzzle.' )
			print()
			prompt()
		print()
		prompt()
	elif solved_places['b1'] == True:
		print('You have solved the WESTERN puzzle.')
		if solved_places['b3'] == True:
			print('You have solved the EASTERN puzzle.')
			if solved_places['c2'] == True:
				print('You have solved the SOUTHERN puzzle.' )
				print()
				prompt()
			print()
			prompt()
		elif solved_places['c2'] == True:
			print('You have solved the SOUTHERN puzzle.' )
			print()
			prompt()
		print()
		prompt()
	elif solved_places['b3'] == True:
		print('You have solved the EASTERN puzzle.')
		if solved_places['c2'] == True:
			print('You have solved the SOUTHERN puzzle.' )
			print()
			prompt()
		print()
		prompt()
	elif solved_places['c2'] == True:
		print('You have solved the SOUTHERN puzzle.' )
		print()
		prompt()

def hints():
	if solved_places['a1'] == False and solved_places['a3'] == False and solved_places['c1'] == False and solved_places['c3'] == False:
		print("You don't know any hints yet.\n")
		prompt()
	elif solved_places['a1'] == True:
		print('You have an [UMBRELLA]. It looks like it could shield you from some serious heat.')
		if solved_places['a3'] == True:
			print('You know that Samuel Beckett authored a play titled Waiting For Godot.')
			if solved_places['c1'] == True:
				print('You recall that Steven Spielberg was a famous movie director.')
				if solved_places['c3'] == True:
					print('For some reason, the word \'dice\' sticks in your mind.' )
					print()
					prompt()
				print()
				prompt()
			elif solved_places['c3'] == True:
				print('For some reason, the word \'dice\' sticks in your mind.' )
				print()
				prompt()
			print()
			prompt()
		elif solved_places['c1'] == True:
			print('You recall that Steven Spielberg was a famous movie director.')
			if solved_places['c3'] == True:
				print('For some reason, the word \'dice\' sticks in your mind.' )
				print()
				prompt()
			print()
			prompt()
		elif solved_places['c3'] == True:
			print('For some reason, the word \'dice\' sticks in your mind.' )
			print()
			prompt()
		print()
		prompt()
	elif solved_places['a3'] == True:
		print('You know that Samuel Beckett authored a play titled Waiting For Godot.')
		if solved_places['c1'] == True:
			print('You recall that Steven Spielberg was a famous movie director.')
			if solved_places['c3'] == True:
				print('For some reason, the word \'dice\' sticks in your mind.' )
				print()
				prompt()
			print()
			prompt()
		elif solved_places['c3'] == True:
			print('For some reason, the word \'dice\' sticks in your mind.' )
			print()
			prompt()
		print()
		prompt()
	elif solved_places['c1'] == True:
		print('You recall that Steven Spielberg was a famous movie director.')
		if solved_places['c3'] == True:
			print('For some reason, the word \'dice\' sticks in your mind.' )
			print()
			prompt()
		print()
		prompt()
	elif solved_places['c3'] == True:
		print('For some reason, the word \'dice\' sticks in your mind.' )
		print()
		prompt()


####################
### EXECUTE GAME ###
####################
start_screen()
