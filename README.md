# Movies - Average Age of Cast

This ruby script fetches the current list of movies showing in
theaters and displays the average age of its cast.

# Installation & Running

To install this, have a ruby installation > `1.9.3`. Use `bundle
install --without development` to get all the gems necessary to run
the script. If you need to play around with the script, feel free to
install everything and use pry to well.. pry.

## Example run:

    Jacob@Jacobs-MacBook-Pro movies-avg-ager [master]
    ± % time ./movies_avg_ager.rb 2>run.log                                        
    Here are the movies showing according to: http://www.imdb.com/showtimes/location?sort=title&ref_=shlc_sort
    Average age for movies showing:
    A Star Is Born (1954) => 72
    Back to the Future (1985) => 60
    Bears (2014) => 49
    Belle (2013) => 42
    Blended (2014) => 40
    Captain America: The Winter Soldier (2014) => 43
    Chef (2014) => 43
    Cold in July (2014) => 51
    Divergent (2014) => 34
    Fading Gigolo (2013) => 49
    Fed Up (2014) => n/a
    God's Pocket (2014) => 52
    Godzilla (2014) => 44
    Grand Canyon Adventure: River at Risk (2008) => 54
    Great White Shark (2013) => n/a
    Heaven Is for Real (2014) => 47
    Island of Lemurs: Madagascar (2014) => 73
    Jerusalem (2013) => 37
    Journey to the South Pacific (2013) => 45
    Kochadaiiyaan (2014) => 50
    Legends of Oz: Dorothy's Return (2013) => 51
    Locke (2013) => 37
    Manam (2014) => 48
    Million Dollar Arm (2014) => 46
    Moms' Night Out (2014) => 46
    Muppets Most Wanted (2014) => 40
    Neighbors (2014) => 31
    Nosferatu the Vampyre (1979) => 70
    Palo Alto (2013) => 43
    Rio 2 (2014) => 43
    Sakasama no Patema (2013) => 49
    Sansho the Bailiff (1954) => 80
    Teenage (2013) => 28
    The Amazing Spider-Man 2 (2014) => 40
    The Grand Budapest Hotel (2014) => 51
    The Immigrant (2013) => 46
    The Kid (2013) => 32
    The Lunchbox (2013) => 53
    The Other Woman (2014) => 37
    The Quiet Ones (2014) => 31
    The Railway Man (2013) => 43
    X-Men: Days of Future Past (2014) => 41
    
    That it, all 42 movies showing.
    ./movies_avg_ager.rb 2> run.log  73.08s user 1.67s system 5% cpu 24:06.14 total
    
STDERR contains log output for redirection.
