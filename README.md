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
    ± % ./movies_avg_ager.rb 2>run.log
    
    Average age for movies showing:
    X-Men: Days of Future Past (2014) => 41
    Blended (2014) => 40
    Cold in July (2014) => 51
    Stand Clear of the Closing Doors (2013) => 51
    Words and Pictures (2013) => 43
    The Angriest Man in Brooklyn (2014) => 50
    The Other Woman (2014) => 37
    Heaven Is for Real (2014) => 47
    Rio 2 (2014) => 43


STDERR contains log output for redirection.
