iosugar
=======

iOS utility methods and functions for making iOS development a little less verbose.

The code is still a bit rough, and there is a fair bit of cruft, but I am happy to say I finally cleaned up iosugar to make it visible to the world.  I don't know if it will help anyone else, but that would be nice.

It contains the various helper categories that I've built up on basic CocoaTouch classes to simplify the hassle of UIView/UIViewController flow, image processing, and various other basic bits of code that you just end up using over and over again.

Probably my most used bit is:

    FMT(@"Foo %d", bar)

as a shorthand for NSString stringWithFormat.  Simple, but it comes up so often that saving even those few words is a massive saving in typing.

It also has handy macros for array creation and NSNumber boxing, but of course those are not really necessary anymore given that the most recent iOS SDK provides object literal syntax that is backwards compatible all the way to 4.x.

One part particularly needs an example to understand: **LazyMenu** makes it very simple to specify a table of options, trivially an array of strings, or a block that returns an array of strings.  Selecting an element triggers an action block, and if that action returns a LazyMenu, you can nest as deep as you like.

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

