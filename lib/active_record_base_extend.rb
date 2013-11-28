module ActiveRecordBaseExtend

  def self.included(model)
    model.extend(ClassMethods)
  end

  module ClassMethods
    def get_instance(arguments_hash)
      if instance = self.find(:first, :conditions => arguments_hash)
      else
        instance = self.create(arguments_hash)
      end

      instance
    end

    def complex_search( options = {} )
      options.each { |k,v| options.delete(k) if v.nil? }

      defaults = Hash.new

      defaults[:where] = ""
      defaults[:what] = ""
      defaults[:order_by] = "id"
      defaults[:order_dir] = 'DESC'

      if options[:what] and options[:where]
        arel = self.where(options[:where].map{|w| w.to_s + " LIKE '" + options[:what].to_s + "'"}.join(" OR "))
      else
        arel = self
      end
      arel = arel.order("#{options[:order_by]} #{options[:order_dir]}")
    end
  end

end

ActiveRecord::Base.class_eval do
  include ActiveRecordBaseExtend
end

