describe 'ReportFragment', ->

  beforeEach module 'am'

  beforeEach inject (ReportFragment, Medium, AMDataStore, $translate) ->
    @dataStore  = AMDataStore.getInstance()
    @fragment   = @dataStore.report_fragments.add()
    @translate  = $translate

  describe '#parent()', ->
    it 'return undefined when no parent is given', ->
      expect( @fragment.parent() ).toBe undefined

    it 'return the parent() if exist', ->
      @parentFragment   = @dataStore.report_fragments.add()
      @fragment.parent_fragment_id =  @parentFragment.id

      expect( @fragment.parent() ).toBe @parentFragment

  describe '#isList()', ->
    beforeEach ->
      @singleChoiceFragment = @dataStore.report_fragments.add( fragment_type: "item_list_single_choice" )
      @multiChoiceFragment  = @dataStore.report_fragments.add( fragment_type: "item_list_multi_choice" )
      @booleanFragment      = @dataStore.report_fragments.add( fragment_type: "boolean" )
      @equipmentFragment    = @dataStore.report_fragments.add( fragment_type: "equipment" )

    it 'return true if the report fragment is an `ìtem_list_single_choice`', ->
      expect( @singleChoiceFragment.isList() ).toBe true

    it 'return true if the report fragment is an `item_list_multi_choice`', ->
      expect( @multiChoiceFragment.isList() ).toBe true

    it 'return false for any other report fragment type', ->
      expect( @booleanFragment.isList() ).toBe false

    it 'return false for any other report fragment type', ->
      expect( @equipmentFragment.isList() ).toBe false

  describe '#formattedtitle()', ->
    beforeEach ->
      @fragment.is_system     = true
      @fragment.fragment_type = 'boolean'

    it 'return the right title if it is about a specification template', ->
      specificationTemplate               = @dataStore.specification_templates.add()
      @fragment.specification_template_id = specificationTemplate.id

      expect( @fragment.formattedTitle() ).toBe @translate.instant 'report_templates.fragment.specification.done'

    it 'return the right title if it is about a consumableType', ->
      consumableType               = @dataStore.consumable_types.add()
      @fragment.consumable_type_id =  consumableType.id

      expect( @fragment.formattedTitle() ).toBe @translate.instant 'consumable_types.reports.default_fragment'

    it 'return the right title if it is about a equipmentType', ->
      equipmentType                = @dataStore.equipment_types.add()
      @fragment.equipment_type_id  = equipmentType.id

      expect( @fragment.formattedTitle() ).toBe @translate.instant 'equipment_types.reports.default_fragment'

    it 'return the @title by default', ->
      expect( @fragment.formattedTitle() ).toBe @fragment.title

  describe '#formattedValue()', ->
    beforeEach ->
      @fragmentDate                 = @dataStore.report_fragments.add(fragment_type: 'date', value: new Date( "2013-10-30T14:45:00+01:00" ) )
      @fragmentDateTime             = @dataStore.report_fragments.add(fragment_type: 'date_time', value: new Date( "2013-10-30T14:45:00+01:00" ) )
      @fragmentTime                 = @dataStore.report_fragments.add(fragment_type: 'time', value: new Date( "2013-10-30T14:45:00+01:00" ))
      @fragmentInterventionStart    = @dataStore.report_fragments.add(fragment_type: 'intervention_start', value: new Date( "2013-10-30T14:45:00+01:00" ) )
      @fragmentInterventionEnd      = @dataStore.report_fragments.add(fragment_type: 'intervention_end', value: new Date( "2013-10-30T14:45:00+01:00" ) )
      @fragmentInterventionDuration = @dataStore.report_fragments.add(fragment_type: 'intervention_duration', value: new Date( "2013-10-30T14:45:00+01:00" ) )
      @fragmentComment              = @dataStore.report_fragments.add(fragment_type: 'comment', value: "Some Comment" )

    it 'return the formatted value for a date fragment', ->
      expect( @fragmentDate.formattedValue() ).toBe 'Oct 30, 2013'

    it 'return the formatted value for a time, intervention_start and intervention_end   fragments', ->
      expect( @fragmentTime.formattedValue()                 ).toBe '14:45'
      expect( @fragmentInterventionStart.formattedValue()    ).toBe '14:45'
      expect( @fragmentInterventionEnd.formattedValue()      ).toBe '14:45'

    it 'return value by default', ->
      expect( @fragmentComment.formattedValue()               ).toBe @fragmentComment.value
      expect( @fragmentInterventionDuration.formattedValue() ).toBe @fragmentInterventionDuration.value

  describe '#isTemplateFragment()', ->
    beforeEach ->
      @parentFragment = @dataStore.report_fragments.add()

    it 'returns undefined when the parent is not ReportFragmentTemplate', ->
      @fragment.parent_fragment_id =  @parentFragment.id
      expect( @fragment.isTemplateFragment() ).toBeFalsy()

    it 'returns false if the parent is related to report sheet instance', ->
      reportSheet = @dataStore.report_sheet_templates.add(is_template: false)
      @fragment.parent_fragment_id    =  @parentFragment.id
      @parentFragment.report_sheet_id = reportSheet.id

      expect( @fragment.isTemplateFragment() ).toBeFalsy()

    it 'returns undefined if the parent is related to report sheet template', ->
      reportSheet = @dataStore.report_sheet_templates.add( is_template: true )
      @fragment.parent_fragment_id    = @parentFragment.id
      @parentFragment.report_sheet_id = reportSheet.id

      expect( @fragment.isTemplateFragment() ).toBe true

    it 'returns true if the parent is related to a consumable', ->
      @parentFragment.consumable_id = @dataStore.consumables.add()
      @fragment.parent_fragment_id  = @parentFragment.id
      expect( @fragment.isTemplateFragment() ).toBe true

    it 'returns true if the parent is related to a consumable_type', ->
      @parentFragment.consumable_type_id = @dataStore.consumable_types.add()
      @fragment.parent_fragment_id       = @parentFragment.id
      expect( @fragment.isTemplateFragment() ).toBe true



  describe 'Visibility helpers', ->

    it "isInternal() returns true if visibility is 'is_internal'", ->
      @fragment.visibility = 'is_internal'
      expect( @fragment.isInternal() ).toBe true

    it "isEditOnly() returns true if visibility is 'is_edit_only'", ->
      @fragment.visibility = 'is_edit_only'
      expect( @fragment.isEditOnly() ).toBe true

    it "returns false if visibility is not set", ->
      @fragment.visibility = undefined
      expect( @fragment.isInternal() ).toBe false
      expect( @fragment.isEditOnly() ).toBe false

    it "returns false if visibility is something else", ->
      @fragment.visibility = "Can't see me."
      expect( @fragment.isInternal() ).toBe false
      expect( @fragment.isEditOnly() ).toBe false


  describe '#conditionalFragments()', ->
    beforeEach ->
      @parentFragment  = @dataStore.report_fragments.add(fragment_type: 'composed')
      @fragment1       = @dataStore.report_fragments.add(fragment_type: 'boolean', parent_fragment_id: @parentFragment.id)
      @fragment2       = @dataStore.report_fragments.add(fragment_type: 'item_list_single_choice', parent_fragment_id: @parentFragment.id )
      @fragment3       = @dataStore.report_fragments.add(fragment_type: 'boolean')
      @fragment4       = @dataStore.report_fragments.add(fragment_type: 'comment', parent_fragment_id: @parentFragment.id )
      @fragment.parent_fragment_id = @parentFragment.id

    it "returns all the conditional fragment that belong to the parent and have type 'boolean'", ->
      expect( @fragment.conditionalFragments() ).toContain @fragment1

    it "returns all the conditional fragment that belong to the parent and have type 'item_list_single_choice'", ->
      expect( @fragment.conditionalFragments() ).toContain @fragment2

    it "will not returns the conditional fragment that not belong to the parent ", ->
      expect( @fragment.conditionalFragments() ).not.toContain @fragment3

    it "will not returns the conditional fragment have type other then 'boolean' and 'item_list_single_choice' ", ->
      expect( @fragment.conditionalFragments() ).not.toContain @fragment4

    it "will avoid the infinite loop ", ->
      @fragment1.conditional_fragment_id = @fragment.id
      expect( @fragment.conditionalFragments() ).not.toContain @fragment1

  describe '#archive()', ->
    beforeEach ->
      @fragment.archive()

    it 'sets is_archived to true', ->
      expect( @fragment.is_archived ).toBe true


  describe '#saveWithChildren()', ->

    it 'should call #saveWithChildren() on each child report fragment', ->
      for i in [1..10]
        fragment = @fragment.report_fragments.create()
        fragment.saveWithChildren = jasmine.createSpy('saveWithChildren')
      @fragment.saveWithChildren()

      for fragment in @fragment.report_fragments()
        expect(fragment.saveWithChildren).toHaveBeenCalled()

    it 'should call #saveWithChildren() on each child medium', ->
      for i in [1..10]
        medium = @fragment.media.create { url: '' }
        medium.saveWithChildren = jasmine.createSpy('saveWithChildren')

      @fragment.saveWithChildren()
      for medium in @fragment.media()
        expect(medium.saveWithChildren).toHaveBeenCalled()

    describe "saving item list", ->
      beforeEach inject (ItemList) ->
        @itemList       = @dataStore.item_lists.add()
        @fragment.value = @itemList.id

        @itemList.save = jasmine.createSpy('save')

      describe "when fragment is of type item_list_single_choice", ->
        it "should call #save() on fragment's item list", ->
          @fragment.fragment_type = 'item_list_single_choice'
          @fragment.saveWithChildren()
          expect(@itemList.save).toHaveBeenCalled()

      describe "when fragment is of type item_list_multi_choice", ->
        it "should call #save() on fragment's item list", ->
          @fragment.fragment_type = 'item_list_multi_choice'
          @fragment.saveWithChildren()
          expect(@itemList.save).toHaveBeenCalled()
