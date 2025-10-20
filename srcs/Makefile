# i am only here for convenience inside the VM

GRN = \e[0;32m
YLW = \e[1;93m
RST = \e[0m
MSGOPN = $(YLW)--(($(GRN)
MSGEND = $(YLW)))--$(RST)
log_msg_single = @echo -e "\n$(MSGOPN) $(1) $(MSGEND)\n"

all:
	$(call log_msg_single,Finally! Launching all Inception services...)
	@sleep 0.5
	docker compose up --build

.PHONY: all
