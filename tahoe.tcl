#Create a simulator object
set ns [new Simulator]

#Open the nam file first.nam and the variable-trace file first.tr
set namfile [open tahoe.nam w]
$ns namtrace-all $namfile
set tracefile [open tahoe.tr w]
$ns trace-all $tracefile

#Define a 'finish' procedure
proc finish {} {
        global ns namfile tracefile
        $ns flush-trace
        close $namfile
        close $tracefile
        exit 0
}

proc generate_rand {min max} {
    return [expr int(rand() * ($max - $min + 1)) + $min]
} 

# set rand_delay [new RandomVariable/Uniform]
# $rand_delay set min_ 5
# $rand_delay set max_ 25

#Create the network nodes
set s1 [$ns node]
set s2 [$ns node]
set m3 [$ns node]
set m4 [$ns node]
set r5 [$ns node]
set r6 [$ns node]

#Create a duplex link between the nodes
$ns duplex-link $s1 $m3 100Mb 5ms DropTail
$ns duplex-link $m3 $m4 100Kb 1ms DropTail
$ns duplex-link $m4 $r5 100Mb 5ms DropTail
$ns duplex-link $s2 $m3 100Mb [generate_rand 5 25]ms DropTail
$ns duplex-link $m4 $r6 100Mb [generate_rand 5 25]ms  DropTail



# The queue size at $m3 and $m4 is to be 10.
$ns queue-limit $m3 $m4 10
$ns queue-limit $m3 $s1 10
$ns queue-limit $m3 $s2 10

$ns queue-limit $m4 $m3 10
$ns queue-limit $m4 $r5 10
$ns queue-limit $m4 $r6 10


# color packets of flow 0 red
$ns color 0 Red
$ns color 1 Blue

$ns duplex-link-op $s1 $m3 orient right-down
$ns duplex-link-op $s2 $m3 orient right-up
$ns duplex-link-op $m3 $m4 orient right
$ns duplex-link-op $m4 $r5 orient right-up
$ns duplex-link-op $m4 $r6 orient right-down
$ns duplex-link-op $m3 $m4 queuePos 0.5
$ns duplex-link-op $m4 $r5 queuePos 0.5
$ns duplex-link-op $m4 $r6 queuePos 0.5

# Create a TCP sending agent and attach it to s1
set tcp1 [new Agent/TCP]
$tcp1 set class_ 0
$tcp1 set fid_ 1
$tcp1 set packetSize_ 1000
$tcp1 set ttlـ 64
$ns attach-agent $s1 $tcp1

#trace vars
$tcp1 attach $tracefile
$tcp1 tracevar cwnd_
$tcp1 tracevar rtt_
$tcp1 tracevar ack_
$tcp1 tracevar maxseq_

# Create a TCP sending agent and attach it to s2
set tcp2 [new Agent/TCP]
$tcp2 set class_ 1
$tcp2 set fid_ 2

$tcp2 set packetSize_ 1000
$tcp2 set ttl_ 64
$ns attach-agent $s2 $tcp2

#trace vars
$tcp2 attach $tracefile
$tcp2 tracevar cwnd_
$tcp2 tracevar rtt_
$tcp2 tracevar ack_
$tcp2 tracevar maxseq_

#Create a TCP receive agent (a traffic sink) and attach it to r5
set tcp5 [new Agent/TCPSink]
$ns attach-agent $r5 $tcp5

#Create a TCP receive agent (a traffic sink) and attach it to r5
set tcp6 [new Agent/TCPSink]
$ns attach-agent $r6 $tcp6

#Connect the traffic source with the traffic sink
$ns connect $tcp1 $tcp5
$ns connect $tcp2 $tcp6


set myftp1 [new Application/FTP]
$myftp1 attach-agent $tcp1
set myftp2 [new Application/FTP]
$myftp2 attach-agent $tcp2

$ns at 0.0 "$myftp1 start"
$ns at 0.0 "$myftp2 start"

$ns at 1000.0 "finish"

#Run the simulation
$ns run