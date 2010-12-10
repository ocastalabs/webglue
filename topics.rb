begin
  require 'system_timer'
  MyTimer = SystemTimer
rescue LoadError
  require 'timeout'
  MyTimer = Timeout
end

# Small fix for feeds with 'xhtml' type content
module Atom
  class Content
    class Xhtml < Base
      def to_xml(nodeonly = true, name = 'content', namespace = nil, namespace_map = Atom::Xml::NamespaceMap.new)
        node = XML::Node.new("#{namespace_map.prefix(Atom::NAMESPACE, name)}")
        node['type'] = 'xhtml'
        # fixed line - FriendFeed send 'xhtml' type content WITHOUT xml_lang :(
        node['xml:lang'] = self.xml_lang ? self.xml_lang : "en"

        div = XML::Node.new('div')
        div['xmlns'] = XHTML

        p = XML::Parser.string(to_s)
        content = p.parse.root.copy(true)
        div << content

        node << div
        node
      end  
    end
  end  
end  

module WebGlue

  class InvalidTopicException < Exception; end

  class Topic

    attr_reader  :entries

    def Topic.to_hash(url)
      [url].pack("m*").strip!
    end

    def Topic.to_url(hash)
      hash.unpack("m")[0]
    end   

    def Topic.sync(url)
      raise InvalidTopicException unless url
      feed = nil
      begin
        MyTimer.timeout(Config::GIVEUP) do
          feed = Atom::Feed.load_feed(URI.parse(url))
        end
      rescue
        raise InvalidTopicException
      end  
      raise InvalidTopicException unless feed
      return feed
    end

    def Topic.load_file(hash)
      path = File.join(Config::FEEDS_DIR,"#{hash}.yml")
      raise InvalidTopicException unless File.exists?(path)
      return YAML::load_file(path)
    end  

    def Topic.load_url(url)
      raise InvalidTopicException unless url
      h = Topic.to_hash(url)
      return Topic.load_file(h)
    end  

    def Topic.save!(url, feed)
      raise InvalidTopicException unless (url and feed)
      h = Topic.to_hash(url)
      File.open(File.join(Config::FEEDS_DIR,"#{h}.yml"), "w") do |out|
        YAML::dump(feed, out)
      end  
    end

    def Topic.diff(url, to_atom = false)
      raise InvalidTopicException unless url
      
      begin
        old_feed = Topic.load_url(url)
        old_entries = old_feed.entries
      rescue InvalidTopicException
        old_entries = []
      end  

      new_feed = nil
      begin
        MyTimer.timeout(Config::GIVEUP) do
          puts "Loading feed #{url}.."
          new_feed = Atom::Feed.load_feed(URI.parse(url))
          puts "Feed has #{new_feed.entries.length} entries"
        end
      rescue Exception => e
        raise e.to_s
      end  
      raise InvalidTopicException unless new_feed

      Topic.save!(url, new_feed)

      # Ensure that all entries has an atom:published element (updated is optional)
      new_feed.entries.delete_if { |entry| entry.published.nil? }

      new_feed.entries.delete_if { |new|
        old = old_entries.find { |o| o.id == new.id }
        break false if old.nil?

        old_timestamp = old.updated.nil? ? old.published : old.updated
        new_timestamp = new.updated.nil? ? new.published : new.updated

        #puts "old_timestamp=#{old_timestamp}, new_timestamp=#{new_timestamp}, updated=" + (new_timestamp > old_timestamp).to_s

        not (new_timestamp > old_timestamp)
      }
      return nil unless old_entries.length > 0 # do not send everything first time
      return nil unless new_feed.entries.length > 0
      return to_atom ? new_feed.to_xml : new_feed.entries
    end
  end
end  
