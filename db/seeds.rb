#
# The Default ICLA Document
#
# Get assign the head.md and body.md Markdown documents in the seeds directory
# to their respective attributes and create an Icla with the configured
# version.
#
attributes = {}

%w(head body).each do |section|
  attributes[section] = open(
    "#{File.dirname(__FILE__)}/seeds/icla/#{section}.md"
  ).read
end

Icla.where(version: Supermarket::Config.icla_version).
  first_or_create!.
  update_attributes(attributes)

#
# The Default CCLA Document
#
# Get assign the head.md and body.md Markdown documents in the seeds directory
# to their respective attributes and create an Ccla with the configured
# version.
#
%w(head body).each do |section|
  attributes[section] = open(
    "#{File.dirname(__FILE__)}/seeds/ccla/#{section}.md"
  ).read
end

Ccla.where(version: Supermarket::Config.ccla_version).
  first_or_create!.
  update_attributes(attributes)

if Rails.env.development?
  #
  # Default category for use in development.
  #
  category = Category.where(name: 'Other').first_or_create!

  #
  # Default cookbooks for use in development.
  #
  %w(redis postgres node ruby haskell clojure java mysql apache2 nginx yum apt).each do |name|
    cookbook = Cookbook.where(
      name: name
    ).first_or_initialize(
      maintainer: Faker::Name.name,
      description: Faker::Lorem.sentences(1).first,
      source_url: 'http://example.com',
      issues_url: 'http://example.com',
      category: category
    )

    # TODO: figure out a nice way to use CookbookUpload here, which will ensure
    # that our seed data is realistically seeded.
    cookbook_version = cookbook.cookbook_versions.where(
      version: '0.1.0'
    ).first_or_initialize(
      license: 'MIT',
      cookbook: cookbook,
      tarball: File.open('spec/support/cookbook_fixtures/redis-test-v1.tgz'),
      readme: File.read('README.md'),
      readme_extension: 'md'
    )

    cookbook.cookbook_versions << cookbook_version
    cookbook.save!
  end

  #
  # Default user for use in development.
  #
  user = User.where(
    first_name: 'John',
    last_name: 'Doe',
    email: 'john@example.com'
  ).first_or_create!

  #
  # Default account for use in development.
  #
  Account.where(
    user: user,
    uid: '123',
    username: 'johndoe',
    provider: 'github',
    oauth_token: '123',
    oauth_secret: '123',
    oauth_expires: Date.parse('Tue, 20 Feb 2024')
  ).first_or_create!

  #
  # Default ICLA Signature for use in development.
  #
  user.icla_signatures.where(
    first_name: 'John',
    last_name: 'Doe',
    email: 'john@example.com',
    phone: '888-555-5555',
    address_line_1: '123 Fake Street',
    city: 'Burlington',
    state: 'Vermont',
    zip: '05401',
    country: 'United States'
  ).first_or_create!(agreement: '1')

  #
  # Default Organization for use in development.
  #
  organization = Organization.first_or_create

  #
  # Default CCLA Signature for use in development.
  #
  user.ccla_signatures.where(
    first_name: 'John',
    last_name: 'Doe',
    email: 'john@example.com',
    phone: '888-555-5555',
    address_line_1: '123 Fake Street',
    city: 'Burlington',
    state: 'Vermont',
    zip: '05401',
    country: 'United States',
    company: 'Chef',
    organization: organization
  ).first_or_create!(agreement: '1')

  #
  # Default Invitation for use in development.
  #
  invitation = Invitation.where(
    email: 'johndoe@example.com',
    organization: organization
  ).first_or_create!
end
