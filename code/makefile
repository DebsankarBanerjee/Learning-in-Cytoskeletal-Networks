compile = gfortran
#
obj_main=code.o initial.o learning.o \
	get_config.o save_data.o forces.o \
	apply_source.o create_source.o \
	relax_sources.o relax_sources_target.o error.o \
	relax.o sawtooth.o quantity.o

obj_parameter=mod_param.o
#
result.exe:$(obj_main) $(obj_parameter)
	$(compile) -O3 $(obj_main) $(obj_parameter) -o result.exe -lm
####
code.o:code.f90 $(obj_parameter)
	$(compile) -c -O3 code.f90 $(obj_parameter)
initial.o:initial.f90 $(obj_parameter)
	$(compile) -c -O3 initial.f90 $(obj_parameter)
get_config.o:get_config.f90 $(obj_parameter)
	$(compile) -c -O3 get_config.f90 $(obj_parameter)
save_data.o:save_data.f90 $(obj_parameter)
	$(compile) -c -O3 save_data.f90 $(obj_parameter)	
learning.o:learning.f90 $(obj_parameter)
	$(compile) -c -O3 learning.f90 $(obj_parameter)
relax_sources.o:relax_sources.f90 $(obj_parameter)
	$(compile) -c -O3 relax_sources.f90 $(obj_parameter)
relax_sources_target.o:relax_sources_target.f90 $(obj_parameter)
	$(compile) -c -O3 relax_sources_target.f90 $(obj_parameter)
error.o:error.f90 $(obj_parameter)
	$(compile) -c -O3 error.f90 $(obj_parameter)
quantity.o:quantity.f90 $(obj_parameter)
	$(compile) -c -O3 quantity.f90 $(obj_parameter)
sawtooth.o:sawtooth.f90 $(obj_parameter)
	$(compile) -c -O3 sawtooth.f90 $(obj_parameter)
create_source.o:create_source.f90 $(obj_parameter)
	$(compile) -c -O3 create_source.f90 $(obj_parameter)
apply_source.o:apply_source.f90 $(obj_parameter)
	$(compile) -c -O3 apply_source.f90 $(obj_parameter)
forces.o:forces.f90 $(obj_parameter)
	$(compile) -c -O3 forces.f90 $(obj_parameter)	
#
mod_param.o:mod_param.f90
	$(compile) -c -O3 mod_param.f90
#
clean:
	rm -f *.o *.mod *.MOD
