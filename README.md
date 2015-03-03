OneTweet
========

Follow the twitter account: <a
href="https://twitter.com/onetweetnotypos">@onetweetnotypos</a>

Created by <a href="http://noj.cc">noj</a>, with major contributions and ideas
from <a href="https://twitter.com/sharonw">Sharon Wong</a>,
<a href="http://www.tatyanabrown.com/">Tatyana Brown</a>,
<a href="https://twitter.com/binaryderrick">Derrick Carr</a>, and
<a href="https://www.facebook.com/pajoux">Philippe Ajoux</a>.

## What would you say if you only had one tweet?

This project is somewhat of a social experiment to see how the culture of an
environment changes given the introduction of new constraints.  In this
specific example, I'd like to see how the theme and tone of what people say on
twitter changes (or doesn't change) if we introduce the constraint of only
being allowed to tweet once ever.

Don't really know what's gonna happen, or if it'll even get used.  The project
is almost designed in a way that would make it not go viral, so I doubt it'll
get much attention, but the attention it gets will be interesting, I'm sure.

## Running Locally

```bash
$ ruby app.rb
```

If using bundler...
```bash
$ bundle exec ruby app.rb
```

Tweeting while in development will log you in using a fake account called
"user" appended with a number.  Every time you tweet it will increment the
number on the user.

Tweets created while in development will not be tweeted to the actual
onetweetnotypos account, but will remain persisted in the local db.


