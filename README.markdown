Viki API gem
============

This gem gives tools to access the Viki.com API.

Installation
------------

Add the gem in your `Gemfile` and run `bundle`

```ruby
gem "viki-api", require: 'viki'
```

Now you need to configure it. In a Rails project you can create a `viki_api.rb` file in your
initializers folder with the following content:

```ruby
Viki.configure do |c|
  # Required fields
  c.salt = 'your_salt'
  c.app_id = 'your_app_id'
  c.user_ip = -> { 'the IP of your user' }
  c.user_token = -> { 'the token of your user' }
  c.addon_headers = -> { 'the hash for additional headers to send in each api call' }
  c.domain = 'the API domain to use'

  # Optional
  c.cache = YOUR_REDIS_INSTANCE
  c.cache_ns = 'namespace_for_your_redis_cache_keys'
  c.cache_seconds = 5 # seconds to cache
  c.logger = Logger.new(STDOUT) # The logger to use from the gem
  c.timeout_seconds = 30 # The timeout for the requests.
  c.max_concurrency = 200 # The number of concurrent connection the Gem can request with
  c.pipelining = true # Allow pipeling in Hydra
  c.memoize = true # Allow same calls to be called only once per batch
  c.ssl = true # False by default - ssl config for http calls
end
```

Installation - Additional notes
------------

##### SSL Connection Error / HTTPS requests via curl

Please note that all api requests are serviced through the [Typhoeus](https://github.com/typhoeus/typhoeus "Typhoeus Github Page") gem, which relies on your system's [libcurl](https://curl.haxx.se). The native libcurl should come with both HTTP and HTTPS protocols for present-day systems

* To debug the version of your libcurl installed on your system, as well as narrowing down the cause of the connection issues, you can view [here](https://github.com/typhoeus/typhoeus#ssl "Typhoeus on SSL issues") .
* To download an updated package for libcurl, please view [here](https://curl.haxx.se/download.html). Additional install solutions for [Windows](http://stackoverflow.com/questions/9507353/how-do-i-install-set-up-and-use-curl-on-windows), [Mac](http://brewformulas.org/Curl), [Mac Upgrade](http://stackoverflow.com/questions/36081761/how-to-update-curl-on-osx-el-capitan), [Ubuntu](http://askubuntu.com/questions/259681/the-program-curl-is-currently-not-installed), [CentOS Install / Upgrade](https://www.digitalocean.com/community/questions/how-to-upgrade-curl-in-centos6)
* Here's a working version review of curl for reference (produced on OS X El Capitan, Version 10.11.6) via `curl --version`. Make sure `http` and `https` protocols are supported:

`curl 7.43.0 (x86_64-apple-darwin15.0) libcurl/7.43.0 SecureTransport zlib/1.2.5
Protocols: dict file ftp ftps gopher http https imap imaps ldap ldaps pop3 pop3s rtsp smb smbs smtp smtps telnet tftp`



Configuration
-------------

* `c.salt` Must contain your application secret. Defaults to `ENV["VIKI_API_SALT"]`. **Required** either explicitly in config, or using `ENV`.

* `c.app_id` Must contain your application id. Defaults to `ENV["VIKI_API_APP_ID"]`. **Required** either explicitly in config, or using `ENV`.

* `c.user_ip` Lambda block returning the IP address of the user. It is put in the header of the requests to the API as `X-FORWARDED-FOR`. **Required**

* `c.user_token` Lambda block returning the session token of the user. **Required**

* `c.addon_headers` Lambda block returning the headers to inject in each api call. **Required**

* `c.domain` The API host to connect to. E.g. `api.viki.io` **Required**


* `c.logger` Instance of `Logger` you want the gem to use. Defaults to `Logger.new(STDOUT)`. **Optional**

* `c.timeout_seconds` Amount of seconds to wait for requests before returning an error. **Optional**

* `c.timeout_seconds_post` Amount of seconds to wait for POST and PUT requests before returning an error. **Optional**

* `c.cache` =  Redis instance where the gem will store cached responses from the API. Defaults to nil. **Optional**

* `c.cache_ns` Namespace for the cache keys stored in Redis. Defaults to `viki-api-gem-cache`. **Optional**

* `c.cache_seconds` Seconds to cache responses from the API. Defaults to 5. **Optional**

* `c.ssl` Boolean value to decide if api endpoints are to be enable ssl. Works with use_ssl. **Optional**

Usage by examples
-----------------

**NOTE:** Remember to run `Viki.run` after fetching.

### Movies, Episodes

#### Fetch a list of episodes

```ruby
Viki::Episode.fetch do |response|
  puts response.value.inspect
end
```

#### Fetch a single episode

```ruby
Viki::Episode.fetch(id: "44699v") do |response|
  puts response.value.inspect
end
```

#### Fetch trending movies (videos)

```ruby
Viki::Movie.trending do |response|
  puts response.value.inspect
end
```

#### Fetch popular TV shows

```ruby
Viki::Series.popular do |response|
  puts response.value.inspect
end
```

#### Fetch upcoming TV shows

```ruby
Viki::Series.upcoming do |response|
  puts response.value.inspect
end
```

#### Fetch container summary

```ruby
Viki::ContainerSummary.fetch(id: '50c') do |response|
  puts response.value.inspect
end
```

### Subtitles

#### Fetch Subtitles

```ruby
Viki::Subtitle.fetch(video_id: "44699v", language: "en") do |response|
  puts response.inspect  # SRT format
end
Viki::Subtitle.fetch(video_id: "44699v", language: "en", format: 'json') do |response|
  puts response.inspect  # JSON format
end
```

#### Fetch Subtitle_completion

```ruby
Viki::SubtitleCompletion.fetch(video_ids: "44699v,44700v") do |response|
  puts response.inspect
end
```

#### Fetch Subtitle_history

```ruby
Viki::SubtitleHistory.fetch(user_id: "1u") do |response|
  puts response.inspect
end
```

#### Fetch recent contributions

```ruby
Viki::RecentContribution.fetch(user_id: "1u") do |response|
  puts response.inspect
end
```

#### Import Subtitles

```ruby
Viki::Srt.import({ video_id: "44699v" }, { language: "en", content: 'subrip text' }) do |response|
  puts response.inspect  # SRT format
end
```

#### Block languages

```ruby
Viki::BlockedLanguages.fetch(container_id: '5269c') do |response|
  puts response.inspect
end
Viki::BlockedLanguages.create({ container_id: '5269c'}, { 'languages' => 'tr,vi' }) do |response|
  puts response.inspect
end
```


### Video

#### Fetch streams for a video

```ruby
Viki::Stream.fetch(video_id: '44699v') do |response|
  puts response.inspect
end
```

#### Creates a master video

```ruby
Viki::MasterVideo.create(video_id: '44699v', url: "YOUTUBE_URL") do |response|
  puts response.inspect
end
```

#### Fetch Master Video

```ruby
Viki::MasterVideo.fetch(video_id: '44699v') do |response|
  puts response.inspect
end
```

#### Fetch Encoding Presets

```ruby
Viki::EncodingPreset.fetch do |response|
  puts response.inspect
end
```

#### Encode Video

```ruby
Viki::EncodeJob.create(video_id: '44699v', profile: 'All') do |response|
  puts response.inspect
end
```

#### Replace Streams

```ruby
Viki::ReplaceStream.update(old_video_id: '44699v', new_video_id: '45566v') do |response|
  puts response.inspect
end
```

#### Fetch container people

```ruby
Viki::ContainerPeople.fetch(id: '50c') do |response|
  puts response.value.inspect
end

Viki::ContainerPeople.update(id: '50c', {[]}) { |r| puts r.inspect }

Viki::ContainerPeople.fetch(id: '50c', language: 'en') do |response| # Fetch the people (cast/directors) involved in a given show, with information localised in the given language
  puts response.value.inspect
end
```

#### Fetch multiple ids from container

```ruby
Viki::Container.fetch(ids:'50c,504c') do |response|
  puts response.value.inspect
end
```

###  Fetch container base on type:

#### Film container

```ruby
Viki::Film.fetch(id:'3466c') do |response|
  puts response.value.inspect
end
```

#### Series container

```ruby
Viki::Series.fetch(id: '50c') do |response|
  puts response.value.inspect
end
```

#### News container

```ruby
Viki::News.fetch(id: '3451c') do |response|
  puts response.value.inspect
end
```

#### Artists container

```ruby
Viki::Artist.fetch(id: '4044c') do |response|
  puts response.value.inspect
end
```

#### Artist - Fetching casts information

```ruby
Viki::Artist.casts_for('4044c') do |response|
  puts response.value.inspect
end
```


#### Fetch container availability
```ruby
Viki::Container.availability('3466c') do |response|
  puts response.value.inspect
end
```

### Others

##### Fetch related news of a particular ID and resource type

```ruby
Viki::RelatedNews.fetch(resource_type: 'celebrities', resource_id: '15203pr', src: 'soompi', language: 'en') do |response|
  puts response.value.inspect
end
```

##### Fetch news from a particular source

```ruby
Viki::RelatedNews.fetch({src: "soompi", language: 'en', news_type:'spotlight'}) do |response|
  puts response.value.inspect
end
```

```ruby
Viki::RelatedNews.fetch(resource_type: 'celebrities', resource_id: '15203pr', src: 'soompi', language: 'en') do |response|
  puts response.value.inspect
end
```

##### Fetch a container cover page

```ruby
Viki::Cover.fetch(container_id: '50c', language: 'en') do |response|
  puts response.value.inspect
end
```

#### Subscribe a user to a container

```ruby
Viki::Subscription.create({user_id: user_id}, {'resource_id' => container_id}) do |response|
  puts response.inspect
end
```

#### List subscribers of a container

```ruby
Viki::Subscriber.fetch(resource_id: resource_id) do |response|
  puts response.inspect
end
```

#### Get language information

```ruby
english = Viki::Language.find('en')
all_language_codes = Viki::Language.codes
```

#### Get country information

```ruby
italy = Viki::Country.find('it')
all_country_codes = Viki::Country.codes
```

#### Get meta country information

```ruby
italy = Viki::MetaCountry.find('rd')
all_country_codes = Viki::Country.codes
```

#### Create a user

```ruby
user_attributes = {first_name: "Tester",
                   last_name: "Lee",
                   email: "tester@example.com",
                   language: 'en',
                   password: "123456",
                   password_confirmation: "123456"}
Viki::User.create({}, user_attributes) do |response|
  puts response.inspect
end
```

#### Update a user

The `token` and the `id` should belong to the same user

```ruby
user_new_attributes = {first_name: "new first name"}
Viki::User.update({id: user_id}, user_new_attributes) do |response|
  puts response.inspect
end
```

#### Fetch user

```ruby
Viki::User.fetch(id: user_id) do |response|
  puts response.inspect
end
Viki::User.fetch(full_id: user_id) do |response|
  puts response.inspect
end
```

#### Fetch user's login history

```ruby
Viki::User.login_history(user_id: user_id) do |response|
  puts response.inspect
end
```

#### Fetch user roles

```ruby
Viki::Role.fetch(user_id: user_id) do |response|
  puts response.inspect
end
```

#### Fetch container roles (staff)

```ruby
Viki::Role.fetch(container_id: container_id) do |response|
  puts response.inspect
end
```

#### Fetch user about page

```ruby
Viki::UserAbout.fetch(user_id: user_id) do |response|
  puts response.inspect
end
```

### User Email Verification

#### Verify a user email

```ruby
Viki::UserPropertyVerify.verify_token(user_id, {property: 'email', verification_token: verification_token}) do |response|
  puts response.inspect
end
```

#### Resend user verification token when user is not logged in

```ruby
Viki::UserPropertyVerify.resend_verification_token(user_id, verification_token, body) do |response|
  puts response.inspect
end
```

#### Resend verification token when user is logged in

```ruby
Viki::UserPropertyVerify.resend_token(user_id, body) do |response|
  puts response.inspect
end
```

### User List

#### Fetch all lists created by users

```ruby
Viki::UserList.fetch do |response|
  puts response.inspect
end
```

#### Fetch user list

```ruby
Viki::UserList.fetch(list_id: list_id) do |response|
  puts response.inspect
end
```

#### Create user list

```ruby
Viki::UserList.create({}, list_json) do |response|
  puts response.inspect
end
```

#### Delete a user list

```ruby
Viki::UserList.destroy(list_id: list_id) do |response|
  puts response.inspect
end
```

#### Login

```ruby
Viki::Session.authenticate('tester@example.com', 'password', {}) do |response|
  puts response.inspect
end

Viki::Session.authenticate('username', 'password', {}) do |response|
  puts response.inspect
end
```

#### Logout

```ruby
Viki::Session.destroy(token: user_token) do |response|
  puts response.inspect
end
```

#### Validate a token

```ruby
Viki::Session.fetch(token: user_token) do |response|
  puts response.inspect
end
```

_Note that a Viki::Core::ErrorResponse will be raised if the token is invalid. This is unlike other methods, which return an error object on failure._

#### Send reset password

```ruby
Viki::ResetPasswordToken.forgot_password!(user_email) do |response|
  puts response.inspect
end
```

#### Update password from reset password token

```ruby
Viki::ResetPasswordToken.reset_password!(reset_password_token, password, password_confirmation) do |response|
  puts response.inspect
end
```

#### Fetch user activities

```ruby
Viki::Activity.fetch(user_id: user_id) do | response |
  puts response.inspect
end
```

#### Fetch activities

```ruby
Viki::Activity.fetch(type: 'all') do | response |
  puts response.inspect
end
```
See http://dev.viki.com/v4/activities/ for type params details

#### Delete user activities

```ruby
body = {
  reset: false,
  watch: ['1v', '2v']
}
Viki::Activity.delete_activity(user_id: user_id, body) do | response |
  puts response.inspect
end
```


#### Private message

```ruby
Viki::Thread.fetch(user_id: user_id, type: 'inbox') { |r| puts r.inspect }                 # Inbox
Viki::Thread.fetch(user_id: user_id, type: 'inbox', unread: true) { |r| puts r.inspect }   # Unread only
Viki::Thread.fetch(user_id: user_id, type: 'sent') { |r| puts r.inspect }                  # Sent
Viki::Thread.fetch(user_id: user_id, id: thread_id) { |r| puts r.inspect }                 # List messages
Viki::Thread.create({user_id: user_id}, to: to_id, content: 'hi') { |r| puts r.inspect }   # Create a thread
Viki::Thread.destroy(user_id: user_id, id: thread_id) { |r| puts r.inspect }               # Delete a thread
Viki::Thread.update(user_id: user_id, id: thread_id, unread: 'true') { |r| puts r.inspect }# Mark thread as Unread
Viki::Thread.update(user_id: user_id, id: thread_id, unread: 'false') { |r| puts r.inspect } # Mark thread as Read
Viki::Message.create({user_id: user_id, thread_id: thread_id}, content: 'hi') { |r| puts r.inspect } # Reply to a thread
Viki::Thread.unread_count(user_id) { |r| puts r.inspect }                                  # Unread count
Viki::Thread.bulk_create(user_id: user_id, usernames: 'user1,user2', content: 'hi') { |r| puts r.inspect } # Create threads with usernames
```

#### [Notification](#notification)

```ruby
Viki::Notification.create({container_id: container_id}, content: 'hi') { |r| puts r.inspect }  # Create an announcement
Viki::Notification.fetch(user_id: user_id) { |r| puts r.inspect }                         # Inbox
Viki::Notification.fetch(user_id: user_id, unread: true) { |r| puts r.inspect }           # Unread
Viki::Notification.fetch(user_id: user_id, id: notification_id) { |r| puts r.inspect }    # Get notification
Viki::Notification.update(user_id: user_id, id: notification_id, unread: true) { |r| puts r.inspect }  # Mark as Unread
Viki::Notification.update(user_id: user_id, id: notification_id, unread: false) { |r| puts r.inspect } # Mark as Read
Viki::Notification.destroy(user_id: user_id, id: notification_id) { |r| puts r.inspect }  # Delete a notification
Viki::Notification.unread_count(user_id) { |r| puts r.inspect }                           # Unread count
```

#### Notification + Private message count

```ruby
Viki::Alert.unread_count(user_id) { |r| puts r.inspect }
```

#### [Contribution](#contribution)

```ruby
Viki::Contribution.fetch(container_id: container_id) { |r| puts r.inspect }   # container specific contributions
Viki::Contribution.fetch(user_id: user_id) { |r| puts r.inspect }             # user specific contributions
Viki::Contribution.mark_as_candidate(user_id: user_id) { |r| puts r.inspect } # apply to be a contributor
Viki::Contribution.count(user_id: user_id) { |r| puts r.inspect }             # user's contribution count
```

#### Title

```ruby
Viki::Title.create({container_id: container_id}, {language_code: 'en', title: 'something'}) do |r|    # Create a container title
  puts r.inspect
end

Viki::Title.create({video_id: video_id}, {language_code: 'en', title: 'something'}) do |r|    # Create a video title
  puts r.inspect
end
```

#### Description

```ruby
Viki::Description.create({container_id: container_id}, {language_code: 'en', description: 'something'}) |r|   # Create a container description
  puts r.inspect
end

Viki::Description.create({video_id: video_id}, {language_code: 'en', description: 'something'}) |r|   # Create a container description
  puts r.inspect
end
```

#### Video Creation/Update

```ruby
Viki::video.create({container_id: container_id}, {type: 'episode', url: 'something'}) |r|   # Create a video
  puts r.inspect
end

Viki::video.update({container_id: container_id, video_id: video_id}, {type: 'episode', url: 'something', part: 2}) |r|   # Update a video
  puts r.inspect
end
```

#### Timed Comments

```ruby
Viki::TimedComment.fetch(video_id: "44699v", language: "en") do |response|
  puts response.inspect  # SRT format
end
Viki::TimedComment.destroy(video_id: "44699v", timed_comment_id: "42tc") do |response|
  puts response.inspect  # JSON format
end
```

#### Ads

```ruby
Viki::Ad.fetch(video_id: '44699v') do |response|
  puts response.inspect
end
```

#### Translations

```ruby
Viki::Translation.fetch(origin_language: 'en', target_language: 'es') do |response| # get translations
  puts r.inspect
end

Viki::Translation.rating(origin_subtitle_id: '1s', target_subtitle_id: '2s', like: true) do |response| # like a translation
  puts r.inspect
end

Viki::Translation.rating(origin_subtitle_id: '1s', target_subtitle_id: '2s', like: false, suggested_content: 'something') do |response| # dislike a translation with suggestion
  puts r.inspect
end

Viki::Translation.report(subtitle_id: '1s') do |response| # report a subtitle
  puts r.inspect
end

Viki::Translation.languages do |response| # get translation languages
  puts r.inspect
end
```

#### Captions

```ruby
Viki::Caption.random(origin_language: 'en', target_language: 'es') do |response| # get random caption
  puts r.inspect
end

Viki::Caption.create(origin_subtitle_id: '1s', language: 'ko', content: 'new caption') do |response| # create a caption
  puts r.inspect
end

Viki::Caption.languages do |response| # get caption languages
  puts r.inspect
end

#### Video Parts

```ruby
Viki::VideoPart.fetch({video_id: video_id}) |r|   # Create a video
  puts r.inspect
end

Viki::VideoPart.create({video_id: video_id}, {end_times: '600000,1200000'}) |r|   # Create a video parts
  puts r.inspect
end
```

#### Badges

```ruby
Viki::Badge.fetch |r|   # Fetch all badges
  puts r.inspect
end

Viki::Badge.fetch({user_id: '1u'}) |r|   # Fetch user's badges
  puts r.inspect
end
```

#### Tracks

```ruby
Viki::Track.fetch |r|   # Fetch all tracks
  puts r.inspect
end
```

#### Wanted Lists

```ruby
Viki::WantedList.fetch(name: 'list_name') |r|   # Fetch a list by name
  puts r.inspect
end

#### Recommendation lists for contributors

```ruby
Viki::Contribution.recommendation_lists |r| # Fetch recommendation lists
  puts r.inspect
end
```

#### Devices for users

```ruby
Viki::Device.link('42u', {'type'=>'roku', 'device_registration_code' => 'dummy_code'})  |r| # Fetch recommendation lists
  puts r.inspect
end

Viki::Device.unlink('42u', {device_token: '42abc'})  |r| # Fetch recommendation lists
  puts r.inspect
end

Viki::Device.fetch(user_id:  '42u')|r| # Fetch recommendation lists
  puts r.inspect
end
```

#### Following

```ruby
Viki::Follow.followings('42u') |r| # Fetch followings of a user (who user is following)
  puts r.inspect
end

Viki::Follow.followers('42u') |r| # Fetch followers of a user (who is following the user)
  puts r.inspect
end
```

####Country by Resource

```ruby
Viki::CountryByResource.fetch(resource: "series") |r| # Fetch countries which have shows originating form for the resource series
  puts r.inspect
end
```

#### Person

```ruby
Viki::Person.languages(person_id: "42pr") |r| # Fetch the languages that have translation for the given person_id
  puts r.inspect
end

Viki::Person.fetch(person_id: "42pr", language: "en") |r| # Fetch the person information with data localised in the given language
  puts r.inspect
end

Viki::Person.honors(person_id: "42pr") |r| # Fetch the honors/awards that the given person_id have
  puts r.inspect
end

Viki::Person.relations(person_id: "42pr", language: "en") |r| # Fetch other people related to the given person_id in the provided language
  puts r.inspect
end

Viki::Person.works(person_id: "42pr", language: "en") |r| # Fetch the works of the given person_id in the provided language
  puts r.inspect
end
```

#### PersonRole

```ruby
Viki::PersonRole.fetch() |r| # Fetch the Role meta information that links a person to a work
  puts r.inspect
end
```

#### RelationType

```ruby
Viki::RelationType.fetch() |r| # Fetch the Relation meta information that relates a person to another person
  puts r.inspect
end
```



### List

#### Fetch List

```ruby
Viki::List.fetch(id: '1l') do |res|
  puts res.inspect
end
```

#### Update List titles & descriptoin

```ruby
Viki::List.update_sync({id: '1l'}, {titles: {en: "title"}, description: {en: "desc"}})
```

#### Delete List

```ruby
Viki::List.destroy_sync({id: '1l'})
```

#### Update List Items

```ruby
Viki::ListItem.update({list_id: '1l'}, {videos: ['1v', '2v']}) do |r|   # Update list items
  puts r.inspect
end
```

#### List Alias

```ruby

Viki::ListAlias.create(list_id: '1l', name: 'alias_for_1l') |r|   # create an alias for the list
  puts r.inspect
end
```

### Bricks

#### Fetch brick

```ruby
Viki::Brick.fetch(id: '1b') do |res|
  puts res.inspect
end
```

#### Update brick

```ruby
Viki::List.update_sync({id: '1b'} {type: "container", resource_id: '1c'})
```

#### Delete a brick

```ruby
Viki::List.destroy_sync({id: '1b'})
```

#### Contributor's count
```ruby
Viki::Contributor.fetch_count(user_id: '1u') do |r|
  puts r.inspect
end
```

#### Contributor's meta info
```ruby
Viki::Contributor.fetch_meta(user_id: '1u') do |r|
  puts r.inspect
end

Viki::Contributor.update_meta(user_id: '1u', languages: 'ja,en') do |r|
  puts r.inspect
end
```

#### Container years
```ruby
Viki::Year.fetch do |r|
  puts r.inspect
end
```

#### Reported users
```ruby
Viki::ReportedUser.fetch do |r|
  puts r.inspect
end
```

### Recaps
#### Get a list of Recaps
```ruby
Viki::Recaps.fetch(video_id: '44699v', language: 'en', source: 'all') do |r|
  put r.inspect
end
```

#### Create a Recap
```ruby
Viki::Recaps.create_recap(body) do |r|
  puts r.inspect
end
```

#### Update a Recap
```ruby
Viki::Recaps.update_recap(recap_id, body) do |r|
  puts r.inspect
end
```

#### Delete a Recap
```ruby
Viki::Recaps.delete_recap(recap_id, body) do |r|
  puts r.inspect
end
```

### Reviews
#### Get a list of Reviews
```ruby
Viki::Review() do |r|
  put r.inspect
end
```

#### Get the languages of a Review
This method accepts `user_id`, `resource_id`, and `user_content_rating` as parameters.

```ruby
Viki::Review.languages(params) do |r|  # Get the languages of a review, accept user_id or resource_id and user_content_rating as params
  puts r.inspect
end
```

#### Create a Review
```ruby
Viki::Review.create_review(resource_id, body) do |r|
  puts r.inspect
end
```

#### Update a Review
```ruby
Viki::Review.update_review(review_id, body) do |r|
  put r.inspect
end
```

#### Update a Review's like
```ruby
Viki::Review.update_like(review_id, body) do |r|
  put r.inspect
end
```

#### Delete a Review
```ruby
Viki::Review.delete_review(review_id, body) do |r|
  put r.inspect
end
```

#### Get Reviews for a Container
```ruby
Viki::Review(container_id: '123c') do |r|
  put r.inspect
end
```

#### Get Reviews by a User
```ruby
Viki::Review(user_id: '123u') do |r|
  put r.inspect
end
```

#### Get Featured Channels
```ruby
Viki::FeaturedChannel() do |r|
  put r.inspect
end
```

#### Get Watch Markers
```ruby
Viki::WatchMarker(user_id: '1u', from: 1455950940) do |r|
  put r.inspect
end
```

#### Get Channel Manager Submissions
```ruby
Viki::ChannelManagerApplications.get(channel_id: '50c', user_id: '42u') do |r|
  put r.inspect
end
```

#### Create Channel Manager Submission
```ruby
Viki::ChannelManagerApplications.post({}, { cm_submission: { channel_id: '50c', user_id: '42u'} } ) do |r|
  put r.inspect
end
```

#### Get Purchaseable Plan Invoice
```ruby
Viki::PurchasablePlanInvoice.fetch(plan_id: "21p") do |r|
  put r.inspect
end
```

#### Get Purchaseable Plans
```ruby
Viki::PurchasablePlans.fetch(features: "noads,hd", verticals: "1pv") do |r|
  put r.inspect
end
```

#### Get Subscription History
```ruby
Viki::VikiSubscriptionHistory.fetch(user_id: '171u') do |r|
  put r.inspect
end
```

#### Get Subscription Status
```ruby
Viki::VikiSubscriptionStatus.fetch(user_id: '10u') do |r|
  put r.inspect
end
```

#### Get Subscription Tracks
```ruby
Viki::SubscriptionTracks.fetch({}) do |r|
  put r.inspect
end
```

Testing Tool
------------

#### Async Stub
Stub value will not be returned immediately when method get called, instead it will be recored and will be returned later when `Viki.run` get called.

###### Setup
Add this line to spec_helper.rb
```ruby
require 'viki_stub'
```
###### Use
Use `async_stub` in replace of `stub`. Example:
```ruby
Viki::User.async_stub(....).with(....).and_yield(...)
```
###### Limitation
Only works with built-in RSpec mock framwork


Releasing new version
---------
Steps to release new version:

* Update version number in `version.rb`
* Run `rake release`. This will update the version number in Gemfile.lock.

Changelog
---------
* 5.1.0
  * Deprecate Viki:Container.recommendations and Viki::Video.recommendations
* 5.0.8
  * Remove cacheable logic on PurchaseablePlans
* 5.0.7
  * Update caching logic to accommodate "public" caching and enable caching for leaderboards endpoints
  * Support login history retrieval on user
* 5.0.6
  * Fixed the configuration implementation of cache_seconds
  * Allow headers to be injected for each endpoint call
* 5.0.5
  * Added purchaseable plan endpoints.
* 5.0.4
  * Added option for configuring ssl for all endpoints.
* 5.0.3
  * Support for channel manager applications endpoint. /cm_submissions
* 5.0.2
  * get_signed_uri on base.rb to allow Gem to return the signed url as a method
* 5.0.1
  * Support for /containers/:availability_for/availability endpoint
* 5.0.0
  * Remove support for User Summary
* 4.0.1
  * Support for property verification endpoint
* 4.0.0
  * Remove hardsub support
* 3.0.6
  * Support for Vikipass apply coupon endpoint
* 3.0.5
  * Support for recaps endpoint
* 3.0.4
  * Support apply_coupon endpoint on VikiSubscription
* 3.0.3
  * Support for user-list and flags endpoint
* 3.0.2
  * Support to verify Viki Pass coupon code through /viki_coupons/coupon_codes/:viki_coupon_code endpoint
* 3.0.1
  * Support for /users/:user_id/watch_markers endpoint
  * Support for DELETE /users/:user_id/activities endpoint
* 3.0.0
  * Adminstrative version bump as 2.2.16 is not backward compatible
  * Deprecate GiftCard endpoint for VikiGiftCard endpoint
  * Subscription endpoint moves to VikiSubscription
* 2.2.16
  * Support for v5 subscription engine.
* 2.2.15
  * Support for /featured_channel endpoint
* 2.2.14
  * Support reviews endpoint
* 2.2.13
  * Support for /related_news endpoint
* 2.2.12
  * Support for /reported_user endpoint
* 2.2.11
  * Support for POST /image endpoint
* 2.2.10
  * Support for POST /people endpoint
* 2.2.9
  * entertainment agencies endpoint to return true source of data
* 2.2.8
  * Support for entertainment agencies endpoint
* 2.2.7
  * Support for resource tags endpoint
* 2.2.6
  * Support for tags endpoint
* 2.2.4
  * Support for trailers endpoint
* 2.2.3
  * Support for container years endpoint
* 2.2.2
  * Support for contributors api resource
* 2.2.1
  * Support for PUT,PATCH,POST /bricks endpoint
  * Support for PUT,PATCH /lists endpoint
* 2.2.0
  * Support for PATCH request
* 2.1.1
  * Support for Person Endpoint
  * Support for RelationType Endpoint
  * Support for PersonRole Endpoint
  * Addition endpoint for ContainerPeople
* 2.1.0
  * Gem logging configuration change. Highly coupled with Viki/Logstash requirement
* 2.0.5
  * Allow Gem to configure max_concurrency for multi threaded application
  * Gem memoize is configuration
  * Gem can configure pipelining
* 2.0.4
  * Country by resource endpoints
* 2.0.3
  * Follow endpoints
* 2.0.2
  * Update viki_utils gem
* 2.0.1
  * Update typhoeus gem.
* 2.0.0
  * Vikipass related refactor, breaks previous version plans, plans subscriber and gift card endpoints
* 1.9.10
  * Recent contribution support
* 1.9.9
  * Include file for 1.9.8 to fix bad publish
* 1.9.8
  * Device linking endpoints
* 1.9.7
  * Expose details attribute as optional extra attributes hash for list responses meta data
* 1.9.6
  * MetaCountry.rb. Support endpoint to get unresolved countries with countries2.json
* 1.9.5
  * Fix thread endpoint to send message and username in the request body
* 1.9.4
  * Fix subtitle import endpoint to send srt content and language in the request body
* 1.9.2
  * Add subtitle import endpoint
* 1.9.1
  * Add bulk creating threads end point
* 1.9.0
  * Move videos and containers endpoints back to v4
  * Specs for user.rb and user_summary.rb
* 1.8.10
  * Add ContainerPeople container/:id/people PUT and GET
* 1.8.9
  * Add send_email endpoint for gift_card
* 1.8.8
  * Add Contribution Recommendation list endpoint
  * Add Wanted list endpoint
  * Add List Alias endpoint
* 1.8.7
  * Add google_auth session support
* 1.8.6
  * Add List Items Endpoint
* 1.8.5
  * Add Badge Endpoint
* 1.8.4
  * Add support for rakuten login via client side
* 1.8.3
  * Add support to allow deleting of titles and description
* 1.8.2
  * Cache to honor cache-control header instead of the default 5 seconds cacheable
* 1.8.1
  * Return error for malform json from api response
* 1.8.0
  * support for session PUT v5
