module topo_reader_mod

  use fiona
  use flogger
  use string
  use const_mod
  use namelist_mod
  use process_mod

  implicit none

  private

  public topo_reader_run
  public topo_reader_final
  public topo_lon, topo_lat, topo_gzs

  real(r8), allocatable :: topo_lon(:)   ! Longitude (degree)
  real(r8), allocatable :: topo_lat(:)   ! Latitude (degree)
  real(r8), allocatable :: topo_gzs(:,:) ! Geopotential (m2 s-2)

contains

  subroutine topo_reader_run(topo_file, min_lon, max_lon, min_lat, max_lat)

    character(*), intent(in) :: topo_file
    real(r8), intent(in) :: min_lon
    real(r8), intent(in) :: max_lon
    real(r8), intent(in) :: min_lat
    real(r8), intent(in) :: max_lat

    call topo_reader_final

    if (proc%is_root()) call log_notice('Use ' // trim(topo_file) // ' as topography.')

    call fiona_open_dataset('topo', file_path=topo_file, mpi_comm=proc%comm, ngroup=input_ngroup)
    select case (topo_type)
    case ('etopo1')
      if (planet /= 'earth') call log_error('Topography file ' // trim(topo_file) // ' is used for the Earth!')
      call fiona_set_dim('topo', 'x', span=[-180, 180], cyclic=.true.)
      call fiona_set_dim('topo', 'y', span=[-90, 90])
      call fiona_start_input('topo')
      call fiona_input_range('topo', 'x', topo_lon, coord_range=[min_lon,max_lon])
      call fiona_input_range('topo', 'y', topo_lat, coord_range=[min_lat,max_lat])
      call fiona_input_range('topo', 'z', topo_gzs, coord_range_1=[min_lon,max_lon], coord_range_2=[min_lat,max_lat])
      topo_gzs = topo_gzs * g
    case ('gmted')
      if (planet /= 'earth') call log_error('Topography file ' // trim(topo_file) // ' is used for the Earth!')
      call fiona_set_dim('topo', 'lon', span=[-180, 180], cyclic=.true.)
      call fiona_set_dim('topo', 'lat', span=[-90, 90])
      call fiona_start_input('topo')
      call fiona_input_range('topo', 'lon', topo_lon, coord_range=[min_lon,max_lon])
      call fiona_input_range('topo', 'lat', topo_lat, coord_range=[min_lat,max_lat])
      call fiona_input_range('topo', 'htopo', topo_gzs, coord_range_1=[min_lon,max_lon], coord_range_2=[min_lat,max_lat])
      topo_gzs = topo_gzs * g
    case ('mola32')
      if (planet /= 'mars') call log_error('Topography file ' // trim(topo_file) // ' is used for the Mars!')
      call fiona_set_dim('topo', 'longitude', span=[0, 360], cyclic=.true.)
      call fiona_set_dim('topo', 'latitude', span=[-90, 90])
      call fiona_start_input('topo')
      call fiona_input_range('topo', 'longitude', topo_lon, coord_range=[min_lon,max_lon])
      call fiona_input_range('topo', 'latitude', topo_lat, coord_range=[min_lat,max_lat])
      call fiona_input_range('topo', 'alt', topo_gzs, coord_range_1=[min_lon,max_lon], coord_range_2=[min_lat,max_lat])
      topo_gzs = topo_gzs * g
    case default
      call log_error('Unknown topo_type "' // trim(topo_type) // '"!', pid=proc%id)
    end select
    call fiona_end_input('topo')

  end subroutine topo_reader_run

  subroutine topo_reader_final()

    if (allocated(topo_lon)) deallocate(topo_lon)
    if (allocated(topo_lat)) deallocate(topo_lat)
    if (allocated(topo_gzs)) deallocate(topo_gzs)

  end subroutine topo_reader_final

end module topo_reader_mod