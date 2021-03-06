class Movie < ActiveRecord::Base
	extend FriendlyId
	friendly_id :name, use: :slugged
	has_many :cinemas, through: :showtimes
	has_many :showtimes, dependent: :destroy

	scope :recent, -> {limit(10).order('created_at DESC')}
#	scope :now_showing, lambda {where("showing_at >= ?", Time.now-30.minutes).order('showing_at ASC')}

	validates :imdb_link, :url => {message: "Messed up the URL there buddy"}, allow_blank: true
	validates :rotten_tomatoes_link, :url => {message: "Moar like a rotten link amirite?"}, allow_blank: true
	validates :name, presence: true, uniqueness: true
	validates :language, presence: true
    validates :language, inclusion: ['English', 'Urdu', 'Punjabi', 'Other']

	has_attached_file :poster, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
	validates_attachment_content_type :poster, :content_type => /^image\/(png|gif|jpeg|jpg)/, :message => 'only (png/gif/jpeg) images'
	validates_attachment :poster, :size => { :in => 0..100.kilobytes }
	validates_attachment_presence :poster, message: "Need a good movie poster"

	def self.currently_showing(cinemas=nil)
		cinemas ||= Cinema.all
		#alternative syntax
		#Movie.joins(:showtimes).merge(Showtime.currently_in_cinemas(cinemas)).uniq_by(&:id)
		Movie.includes(:showtimes, :cinemas).where('showtimes.showing_at >= ? AND cinemas.id in(?)', Time.now-30.minutes, cinemas).order('movies.name ASC').references(:showtimes, :cinemas)
	end

end