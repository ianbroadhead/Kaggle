
use strict;
use Math::Trig qw(deg2rad pi great_circle_distance asin acos);
use Data::Dumper;

use constant MAX_WEIGHT => 1000;
use constant CURRENT_BEST => 12400564441.16660;

my @north_pole = (90,0);

my @item;

my (@trips, @tripWeight,@tripWeariness);
my $total_distance;
my $reindeerWeariness = 0;
my $baseWeight = 10;

sub Haversine {
  my ($lat1, $long1, $lat2, $long2) = @_;
  my $r = 6372.8;
  # my $r=3956;   # Miles

               
  my $dlong = deg2rad($long1) - deg2rad($long2);
  my $dlat  = deg2rad($lat1) - deg2rad($lat2);

  my $a = sin($dlat/2)**2 + cos(deg2rad($lat1)) 
                    * cos(deg2rad($lat2))
                    * sin($dlong/2)**2;
  my $c = 2 * (asin(sqrt($a)));
  my $dist = $r * $c;               


return $dist;

}

# my $distance = Haversine(45.7597, 4.8422, 48.8567, 2.3508);
# die $distance;

sub calculateWeariness
{
	my ($apTrip) = (shift);
	
	my $Weariness = 0;
	
	my $totWeight = $baseWeight;
	my @thisTrip = ([@north_pole,$baseWeight]);   # long, lat, weight    starting point
	for my $ap ( @$apTrip ) {
		# Loop for each of the items on the sleigh for this trip
		
		my ($item, $Latitude,$Longitude, $Weight) = (@$ap);
		$totWeight += $Weight;
		#$_->[2] += $Weight for (@thisTrip );    # Add this weight to previous segments
		push @thisTrip, [$Latitude,$Longitude, $Weight]
	}
	push @thisTrip, [@north_pole,$baseWeight];
	for ( my $i = $#thisTrip - 1 ; $i >= 0 ; $i-- ) {
		$thisTrip[$i]->[2] += $thisTrip[$i + 1]->[2]
	}
	
	for ( my $i = 0 ; $i < $#thisTrip ; $i++ ) {
		my $cost = Haversine( $thisTrip[$i]->[0], $thisTrip[$i]->[1], $thisTrip[$i+1]->[0], $thisTrip[$i+1]->[1]) 
		         * $thisTrip[$i + 1]->[2];
	    #print "cost $cost $thisTrip[$i]->[0], $thisTrip[$i]->[1]
		#                       , $thisTrip[$i+1]->[0], $thisTrip[$i+1]->[1]) * $thisTrip[$i + 1]->[2]\n";
		$Weariness += $cost
	}

    return $Weariness;

}

my $rows;

#my $tmpW = 0;

open(FIN, "<gifts.csv") or die "Could not open gifts.csv";
while(<FIN>) {
	#next if ++$rows > 2;
	
	next if /^GiftId,Latitude,Longitude,Weight/;
	chomp;
	my ($GiftId,$Latitude,$Longitude,$Weight) = split(',');
	my $distance = Haversine(@north_pole, ,$Latitude,$Longitude);
	my $rand = rand() * log($Weight);
	push @item, [$GiftId,$Latitude,$Longitude,$Weight,$distance,$rand];
	#print "$GiftId,$Latitude,$Longitude,$Weight,$distance\n";

	# Start with the hypothesis that each trip carries one present
	my @apThisTrip = [$#item, $Latitude,$Longitude, $Weight];
	push @trips, \@apThisTrip;
	my $Weariness = calculateWeariness($trips[-1]);
	push @tripWeight, $Weight;
	push @tripWeariness, $Weariness;
	
	#$tmpW += ( Haversine( @north_pole, $Latitude,$Longitude) * ($Weight + $baseWeight + $baseWeight));
	
	$reindeerWeariness += $Weariness; # (((MAX_WEIGHT + $Weight) * $distance) + ($baseWeight * $distance));
}
close(FIN);

my $ratio = $reindeerWeariness / CURRENT_BEST;
print "Completed with a weariness of $reindeerWeariness (ratio is $ratio)\n";

# Massive string

my @tripString;
my $itemNumber = 0;
for ( sort { $b->[5] <=> $a->[5] } @item )
{
	if ( $itemNumber == 0 ) {
		push @tripString, $itemNumber
	} else {
		# Now now fit this item into the string
		my ($centre_long, $centre_lat) = ($_->[]])
	}
	push @tripString, $itemNumber if $itemNumber == 0 || $itemNumber == $#item;
	$itemNumber++;
}

	#my $rand = rand();
	#push @item, [$GiftId,$Latitude,$Longitude,$Weight,$distance,$rand];

=pod

Ideas: 

1. Genetic selection and random swaps
2. Put all trips together into one big string, sorted by distance from each other. Thinking here of calculating distance
   as both sides.


For this competition, you are asked to optimize the total weighted distance traveled (weighted reindeer weariness). 
You are given a list of gifts with their destinations and their weights. 
You will plan sleigh trips to deliver all the gifts to their destinations while optimizing the routes. 

All sleighs start from north pole, then head to each gift in the order that you assign, and then head back to north pole. 
You may have an unlimited number of sleigh trips.
All the gifts must be traveling with the sleigh at all times until the sleigh delivers it to the destination. 
A gift may not be dropped off anywhere before it's delivered. 
Sleighs have a base weight of 10, and a maximum weight capacity of 1000 (excluding the sleigh). 
All trips are flying trips, which means you don't need to travel via land. Haversine is used in calculating distance.  













master.exploder@deepsense.io  Team *    12400564441.16660     43	Sun, 13 Dec 2015 10:51:18





import sqlite3
import pandas as pd
from haversine import haversine

north_pole = (90,0)
weight_limit = 1000.0

def bb_sort(ll):
    s_limit = 1000
    optimal = False
    ll = [[0,north_pole,10]] + ll[:] + [[0,north_pole,10]] 
    while not optimal:
        optimal = True
        for i in range(1,len(ll) - 2):
            lcopy = ll[:]
            lcopy[i], lcopy[i+1] = ll[i+1][:], ll[i][:]
            if path_opt_test(ll[1:-1]) > path_opt_test(lcopy[1:-1]):
                #print("swap")
                ll = lcopy[:]
                optimal = False
                s_limit -= 1
                if s_limit < 0:
                    optimal = True
                    break
    return ll[1:-1]

def path_opt_test(llo):
    f_ = 0.0
    d_ = 0.0
    l_ = north_pole
    for i in range(len(llo)):
        d_ += haversine(l_, llo[i][1])
        f_ += d_ * llo[i][2]
        l_ = llo[i][1]
    d_ += haversine(l_, north_pole)
    f_ += d_ * 10 #sleigh weight for whole trip
    return f_

gifts = pd.read_csv("../input/gifts.csv").fillna(" ")
c = sqlite3.connect(":memory:")
gifts.to_sql("gifts",c)
cu = c.cursor()
cu.execute("ALTER TABLE gifts ADD COLUMN 'TripId' INT;")
cu.execute("ALTER TABLE gifts ADD COLUMN 'i' INT;")
cu.execute("ALTER TABLE gifts ADD COLUMN 'j' INT;")
c.commit()


for n in [2]:
    i_ = 0
    j_ = 0
    for i in range(90,-90,int(-180/n)):
        i_ += 1
        j_ = 0
        for j in range(180,-180,int(-360/n)):
            j_ += 1
            cu = c.cursor()
            cu.execute("UPDATE gifts SET i=" + str(i_) + ", j=" + str(j_) + " WHERE ((Latitude BETWEEN " + str(i - (180/n)) + " AND  " + str(i) + ") AND (Longitude BETWEEN " + str(j - (360/n)) + " AND  " + str(j) + "));")
            c.commit()
    
    for limit_ in [65]:
        trips = pd.read_sql("SELECT * FROM (SELECT * FROM gifts WHERE TripId IS NULL ORDER BY i, j, Longitude, Latitude LIMIT " + str(limit_) + " ) ORDER BY Latitude DESC",c)
        t_ = 0
        while len(trips.GiftId)>0:
            g = []
            t_ += 1
            w_ = 0.0
            for i in range(len(trips.GiftId)):
                if (w_ + float(trips.Weight[i]))<= weight_limit:
                    w_ += float(trips.Weight[i])
                    g.append(trips.GiftId[i])
            cu = c.cursor()
            cu.execute("UPDATE gifts SET TripId = " + str(t_) + " WHERE GiftId IN(" + (",").join(map(str,g)) + ");")
            c.commit()
        
            trips = pd.read_sql("SELECT * FROM (SELECT * FROM gifts WHERE TripId IS NULL ORDER BY i, j, Longitude, Latitude LIMIT " + str(limit_) + " ) ORDER BY Latitude DESC",c)
            #break
        
        ou_ = open("submission_opt" + str(limit_) + " " + str(n) + ".csv","w")
        ou_.write("TripId,GiftId\n")
        bm = 0.0
        submission = pd.read_sql("SELECT TripId FROM gifts GROUP BY TripId ORDER BY TripId;", c)
        for s_ in range(len(submission.TripId)):
            trip = pd.read_sql("SELECT GiftId, Latitude, Longitude, Weight FROM gifts WHERE TripId = " + str(submission.TripId[s_]) + " ORDER BY Latitude DESC, Longitude ASC;",c)
            a = []
            for x_ in range(len(trip.GiftId)):
                a.append([trip.GiftId[x_],(trip.Latitude[x_],trip.Longitude[x_]),trip.Weight[x_]])
            b = bb_sort(a)
            if path_opt_test(a) <= path_opt_test(b):
                print(submission.TripId[s_], "No Change", path_opt_test(a) , path_opt_test(b))
                bm += path_opt_test(a)
                for y_ in range(len(a)):
                    ou_.write(str(submission.TripId[s_])+","+str(a[y_][0])+"\n")
            else:
                print(submission.TripId[s_], "Optimized", path_opt_test(a) - path_opt_test(b))
                bm += path_opt_test(b)
                for y_ in range(len(b)):
                    ou_.write(str(submission.TripId[s_])+","+str(b[y_][0])+"\n")
        ou_.close()
        
        benchmark = 12552862884.69230
        if bm < benchmark:
            print(n, limit_, "Improvement", bm, bm - benchmark, benchmark)
        else:
            print(n, limit_, "Try again", bm, bm - benchmark, benchmark)
        cu = c.cursor()
        cu.execute("UPDATE gifts SET TripId = NULL;")
        c.commit()
        