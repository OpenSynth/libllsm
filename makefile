export FP_TYPE ?= double
CC ?= cc
LINK ?= cc
LDFLAGS += -fopenmp -llapacke -llapack -lcblas -lm
AR = ar
CFLAGS = -Ofast -std=c99 -Wall -fPIC -fopenmp -DFP_TYPE=$(FP_TYPE)
ARFLAGS = -rv
OUT_DIR = ./build
OBJS = $(OUT_DIR)/fftsg_h.o $(OUT_DIR)/math-funcs.o $(OUT_DIR)/llsm.o $(OUT_DIR)/envelope.o $(OUT_DIR)/qhm.o
LIBS =
LIBPYIN = external/libpyin
LIBGVPS = $(LIBPYIN)/external/libgvps

default: $(OUT_DIR)/libllsm.a
test: $(OUT_DIR)/llsm-test
	$(OUT_DIR)/llsm-test test/arctic_a0001.wav
testapprox: $(OUT_DIR)/check-approx
	$(OUT_DIR)/check-approx

$(OUT_DIR)/llsm-test: $(OUT_DIR)/libllsm.a test/test.c external/matlabfunctions.c $(LIBGVPS)/build/libgvps.a $(LIBPYIN)/build/libpyin.a
	$(LINK) $(CFLAGS) -o $(OUT_DIR)/llsm-test test/test.c external/matlabfunctions.c $(OUT_DIR)/libllsm.a $(LIBPYIN)/build/libpyin.a $(LIBGVPS)/build/libgvps.a $(LDFLAGS)

$(OUT_DIR)/check-approx: $(OUT_DIR)/libllsm.a test/check-approx.c external/matlabfunctions.c
	$(CC) $(CFLAGS) -o $(OUT_DIR)/check-approx test/check-approx.c external/matlabfunctions.c $(OUT_DIR)/libllsm.a -lm

$(LIBGVPS)/build/libgvps.a:
	cd $(LIBGVPS); mkdir -p build; make

$(LIBPYIN)/build/libpyin.a: $(LIBGVPS)//build/libgvps.a
	cd $(LIBPYIN); mkdir -p build; make

$(OUT_DIR)/libllsm.a: $(OBJS)
	$(AR) $(ARFLAGS) $(OUT_DIR)/libllsm.a $(OBJS) $(LIBS)
	@echo Done.

$(OUT_DIR)/math-funcs.o : math-funcs.c math-funcs.h common.h
$(OUT_DIR)/llsm.o : llsm.c llsm.h envelope.h math-funcs.h common.h
$(OUT_DIR)/envelope.o : envelope.c envelope.h math-funcs.h common.h
$(OUT_DIR)/qhm.o: qhm.h qhm.c math-funcs.h common.h llsm.h

$(OUT_DIR)/fftsg_h.o : external/fftsg_h.c
	mkdir -p build
	$(CC) $(CFLAGS) -o $(OUT_DIR)/fftsg_h.o -c external/fftsg_h.c

$(OUT_DIR)/%.o : %.c
	mkdir -p build
	$(CC) $(CFLAGS) -o $(OUT_DIR)/$*.o -c $*.c

install: $(OUT_DIR)/libllsm.a
	cp $(OUT_DIR)/libllsm.a /usr/lib/
	cp llsm.h /usr/include/
	@echo Done.

clean:
	@echo 'Removing all temporary binaries... '
	@rm -f $(OUT_DIR)/libllsm.a $(OUT_DIR)/*.o
	@echo Done.

clear:
	@echo 'Removing all temporary binaries... '
	@rm -f $(OUT_DIR)/libllsm.a $(OUT_DIR)/*.o
	@echo Done.
