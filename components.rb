class Sketchup::Group
    def definition()
        # http://www.thomthom.net/thoughts/2012/02/definitions-and-instances-in-sketchup/
        if entities.parent.instances.include?(self)
            return instance.entities.parent
        end
        return entities.model.definitions.find() {|d|
            d.instances.include?(self)
        }
    end
end

class Sketchup::ComponentInstance
    def entities()
        # Allow for "transparent" use of Groups/Components
        # This has a possible pitfall in that you may not wish to modify all
        # instances, in which case you can specify by calling #make_unique
        # i.e., passing this point means accepting you may be modifying
        # more than one instance
        return definition.entities
    end
end

class Sketchup::ComponentDefinition
    def erase!()
        # At the moment this raises an exception - this should "purge" the
        # definition from the model - unless it has any instances, in which
        # case it throws an error( RuntimeError? )
        # This could also be aliased as purge!
        trans = Geom::Transformation.new()
        saves = self.model.definitions.find_all() {|d|
            d != self && d.instances.length.zero?
        }.map() {|d|
            self.model.active_entities.add_instance(d, trans)
        }
        self.model.definitions.purge_unused
        self.model.erase_entities(saves)
    end
end

class Sketchup::DefinitionList
    def erase_memebers!(definition_or_array_of_definitions)
        # Bulk erase method. This should (if possible) be more efficient than
        # arr.each() {|d| e.erase! } (and take only one operation)
        definition_or_array_of_definitions.each() {|d| d.erase! }
    end
end