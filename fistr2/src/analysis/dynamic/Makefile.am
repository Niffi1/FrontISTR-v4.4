MAKE = @make@

all: @build_target@

@build_target@:
	@cd mode    && $(MAKE) @build_target@
	@cd transit && $(MAKE) @build_target@

clean:
	@cd mode    && $(MAKE) clean
	@cd transit && $(MAKE) clean

distclean:
	@cd mode    && $(MAKE) distclean
	@cd transit && $(MAKE) distclean

install:
