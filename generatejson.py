
def crongen(time,day):
	time=[int (time[0:2]), int (time[2:])]
	if (time[0]<0 or time[0]>24) or (time[1]<0 or time[1]>60):
		print "Error: Values out of limit. Enter UTC time again in hhmm format"
		time1=raw_input()
		cron=crongen(time1,day)
	else:
		cron='cron(%d %d ? * %s *)' %(time[1],time[0],day)
	return cron

print "Start Instance on Monday: Enter UTC time in hhmm format"
time=raw_input()
a1=crongen(time,2)
print "Stop Instance on Monday: Enter UTC time in hhmm format"
time=raw_input()
b1=crongen(time,2)

print "Start Instance on Tuesday: Enter UTC time in hhmm format"
time=raw_input()
a2=crongen(time,3)
print "Stop Instance on Tuesday: Enter UTC time in hhmm format"
time=raw_input()
b2=crongen(time,3)

print "Start Instance on Wednesday: Enter UTC time in hhmm format"
time=raw_input()
a3=crongen(time,4)
print "Stop Instance on Wednesday: Enter UTC time in hhmm format"
time=raw_input()
b3=crongen(time,4)

print "Start Instance on Thursday: Enter UTC time in hhmm forman"
time=raw_input()
a4=crongen(time,5)
print "Stop Instance on Thursday: Enter UTC time in hhmm format"
time=raw_input()
b4=crongen(time,5)

print "Start Instance on Friday: Enter UTC time in hhmm format"
time=raw_input()
a5=crongen(time,6)
print "Stop Instance on Friday: Enter UTC time in hhmm format"
time=raw_input()
b5=crongen(time,6)

print "Start Instance on Saturday: Enter UTC time in hhmm format"
time=raw_input()
a6=crongen(time,7)
print "Stop Instance on Saturday: Enter UTC time in hhmm format"
time=raw_input()
b6=crongen(time,7)

print "Start Instance on Sunday: Enter UTC time in hhmm format"
time=raw_input()
a7=crongen(time,1)
print "Stop Instance on Sunday: Enter UTC time in hhmm format"
time=raw_input()
b7=crongen(time,1)


json='{"Mon":[{"startcron":"%s","stopcron":"%s"}],"Tue":[{"startcron":"%s","stopcron":"%s"}],"Wed":[{"startcron":"%s","stopcron":"%s"}],"Thu":[{"startcron":"%s","stopcron":"%s"}],"Fri":[{"startcron":"%s","stopcron":"%s"}],"Sat":[{"startcron":"%s","stopcron":"%s"}],"Sun":[{"startcron":"%s","stopcron":"%s"}]}'%(a1,b1,a2,b2,a3,b3,a4,b4,a5,b5,a6,b6,a7,b7)
f=open("weekly.json", "w+")
f.write(json)
f.close()