# Set the base image to the latest version of Ubuntu
FROM ubuntu:latest

# Declare build-time arguments for the username, password, and timezone
ARG TZ=Etc/UTC
ARG USERNAME=admin
ARG PASSWORD=admin

# Update the package list, upgrade installed packages, and install necessary packages
RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y \
  systemd \
  curl \
  wget \
  cups \
  cups-client \
  cups-bsd \
  cups-filters \
  foomatic-db-compressed-ppds \
  printer-driver-all \
  printer-driver-cups-pdf \
  openprinting-ppds \
  hpijs-ppds \
  hp-ppd \
  hplip \
  samba && \
  rm -rf /var/lib/apt/lists/*

# Expose port 631 for CUPS
EXPOSE 631

# Copy the CUPS configuration files into the temporary directory
RUN mkdir /etc/cup && cp -rpn /etc/cups/* /etc/cup

# Declare a volume for the CUPS configuration
VOLUME /etc/cups

# Copy the entrypoint script into the container and make it executable
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set the entrypoint to the custom script
CMD ["/usr/local/bin/entrypoint.sh"]

# Delete the temporary CUPS configuration directory
RUN rm -rf /etc/cup

# Modify the CUPS and Samba configuration files
RUN sed -i "s/Listen localhost:631/Listen *:631/" /etc/cups/cupsd.conf && \
  sed -i "s/Browsing No/Browsing On/" /etc/cups/cupsd.conf && \
  sed -i "s/workgroup = WORKGROUP/workgroup = WORKGROUP\n   security = user/" /etc/samba/smb.conf

# Clean up temporary files to reduce image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*