require 'rexml/xmldecl'

module Phantom
  module SVG
    module Parser
      # convert single quotes into double quotes.
      class PhantomXMLDecl < REXML::XMLDecl
        private

        def content(enc)
          rv = "version=\"#{@version}\""
          rv << " encoding=\"#{enc}\"" if @writeencoding || enc !~ /\Autf-8\z/i
          rv << " standalone=\"#{@standalone}\"" if @standalone
          rv
        end
      end
    end
  end
end
