"use client"

import * as React from "react"
import { ChevronDownIcon } from "lucide-react"
import { format } from "date-fns"
import { ptBR } from "date-fns/locale"
import { buttonVariants } from "@/components/ui/button"
import { Calendar } from "@/components/ui/calendar"
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover"
import { cn } from "@/lib/utils"

interface DatePickerProps {
  value?: string
  onChange: (date: string) => void
  className?: string
  size?: "sm" | "default"
  placeholder?: string
}

export function DatePicker({
  value,
  onChange,
  className,
  size = "default",
  placeholder = "Data",
}: DatePickerProps) {
  const [open, setOpen] = React.useState(false)

  const selectedDate = value ? new Date(value) : undefined

  return (
    <Popover open={open} onOpenChange={setOpen}>
      <PopoverTrigger
        type="button"
        className={cn(
          buttonVariants({ variant: "outline", size }),
          "justify-between font-normal bg-white",
          size === "sm" ? "w-36" : "w-48",
          className
        )}
      >
        {selectedDate
          ? format(selectedDate, "dd/MM/yyyy")
          : placeholder}
        <ChevronDownIcon className="size-3.5 opacity-50" />
      </PopoverTrigger>
      <PopoverContent className="w-auto overflow-hidden p-0" align="start">
        <Calendar
          mode="single"
          selected={selectedDate}
          captionLayout="dropdown"
          locale={ptBR}
          onSelect={(date) => {
            if (!date) return
            const formatted = format(date, "yyyy-MM-dd")
            onChange(formatted)
            setOpen(false)
          }}
        />
      </PopoverContent>
    </Popover>
  )
}
