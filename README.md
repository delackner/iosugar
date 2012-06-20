iosugar
=======

iOS utility methods and functions for making iOS development a little less verbose.

Most recent addition: LazyMenu makes it very simple to specify a table of options, trivially an array of strings, or a block that returns an array of strings.  Selecting an element triggers an action block, and if that action returns a LazyMenu, you can nest as deep as you like.

    LazyMenu* mainMenu = [LazyMenu new];
    LazyMenu* nextMenu = [LazyMenu new];
    LazyMenu* thirdMenu = [LazyMenu new];

    mainMenu.menus = ARRAY(MakeMenu(@"MenuTitle", ARRAY(@"T0", @"T1"), nil), 
                           nextMenu);

    nextMenu.title = @"SubMenuTitle";
    nextMenu.menus = ARRAY(@"A", @"B", @"C");
    nextMenu.action = ^(NSArray* p){ return thirdMenu; };
    
    thirdMenu.menus = ARRAY(@"1", @"2", @"3");
    thirdMenu.action = ^(NSArray* p){
        LazyMenu* m = [LazyMenu new];
        m.menus = [self buildEntries: path];
        m.action = ^(NSArray* p){
	    // maybe push another viewController, whatever.
            return (LazyMenu*)nil; 
        };

        // since the menu entries are all strings that might carry internally important info
        // but you don't need the users to see that info, you can specify a cell formatter:
        m.formatter = ^(UITableViewCell* cell){ 
            NSArray* a = [cell.textLabel.text componentsSeparatedByString: @"\t"];
            cell.textLabel.text = [[[a $0] componentsSeparatedByString: @"//"] $0];
            cell.textLabel.font = [UIFont systemFontOfSize: 16];
        };
        return m;
};

